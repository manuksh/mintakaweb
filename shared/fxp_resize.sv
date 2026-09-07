// ============================================================================
// File:         fxp_resize.sv
// Project:      FPGA SDR IP Library
// Description:  Fixed-point format resize utility.
//               Performs fractional alignment, optional rounding, and optional
//               saturation while converting between signed fixed-point formats.
//
//               Uses Q-format notation: Qm.n where
//                 m = total_width - frac_bits   (integer bits, including sign)
//                 n = frac_bits                  (fractional bits)
//
//               Architecture (four-stage combinational datapath):
//                 1. Sign Extend -- replicate sign bit to working width
//                 2. Frac Align  -- left-shift (upsize) or right-shift (downsize)
//                 3. Round       -- apply one of three rounding modes
//                 4. Saturate    -- clamp or pass-through on overflow
//
//               Latency: 0 cycles (purely combinational)
//               Dependencies: sdr_types_pkg (ROUND_TRUNCATE, ROUND_NEAREST, ROUND_CONVERGENT)
// ============================================================================
// Author:        Mintaka Engineering Team
// Created:       2026-05-14
// Version:       1.0.0
// ============================================================================

`ifndef FXP_RESIZE_SV
`define FXP_RESIZE_SV

module fxp_resize
    import sdr_types_pkg::*;
#(
    // --- Fixed-Point Format Parameters ---
    // Q-format: input  = Q(kInWidth - kInFracBits).kInFracBits
    //           output = Q(kOutWidth - kOutFracBits).kOutFracBits
    parameter int kInWidth          = 24,          // Total bit-width of input (including sign)
    parameter int kOutWidth         = 16,          // Total bit-width of output (including sign)
    parameter int kInFracBits       = 15,          // Number of fractional bits in input format
    parameter int kOutFracBits      = 15,          // Number of fractional bits in output format

    // --- Rounding Mode ---
    // ROUND_TRUNCATE   (0): Discard fractional bits, round toward -infinity (floor)
    // ROUND_NEAREST    (1): Round to nearest, ties away from zero (half-up)
    // ROUND_CONVERGENT (2): Round to nearest, ties to even (IEEE 754 / banker's)
    parameter int kRoundMode        = ROUND_TRUNCATE,

    // --- Saturation Control ---
    // 1'b1: Clamp overflow to MAX_POSITIVE or MIN_NEGATIVE
    // 1'b0: Allow two's-complement wraparound (overflow flag still asserts)
    parameter bit kEnableSaturation = 1'b1
) (
    // --- Data Interface ---
    input  logic signed [kInWidth-1:0]  data_in,     // Input sample in source Q-format
    output logic signed [kOutWidth-1:0] data_out,    // Output sample in destination Q-format

    // --- Side-Channel Status ---
    output logic                         rounded_up,  // Asserted when rounding increased the value
    output logic                         overflow,    // Asserted when result exceeds output range (pre-saturation)
    output logic                         saturated    // Asserted when output was clamped to min/max
);

    // =========================================================================
    // Local Parameters -- computed at elaboration time
    // =========================================================================

    // Fractional upshift: number of bits to left-shift when output has more frac bits.
    // Example: Q1.15 -> Q1.31  =>  shift left by 16, zero-filling new LSBs
    localparam int kFracUpshift   = (kOutFracBits > kInFracBits) ? (kOutFracBits - kInFracBits) : 0;

    // Fractional downshift: number of bits to right-shift when output has fewer frac bits.
    // This is where precision is lost; rounding logic applies.
    // Example: Q1.23 -> Q1.15  =>  shift right by 8, discarding 8 LSBs
    localparam int kFracDownshift = (kInFracBits > kOutFracBits) ? (kInFracBits - kOutFracBits) : 0;

    // Working width provides headroom for intermediate arithmetic:
    //   kInWidth + kFracUpshift  -- aligns the binary point
    //   +2                        -- guard bits:
    //       bit 0: carry from rounding increment (adding lsb_half to max value)
    //       bit 1: one more carry bit (value already at max + round pushes beyond)
    localparam int kWorkWidth     = kInWidth + kFracUpshift + 2;

    // Reject invalid fixed-point formats at simulation startup. Fractional bits
    // must leave at least one signed integer bit (the sign bit) in each format.
    initial begin
        assert (kInWidth > 0)
            else $fatal(1, "fxp_resize: kInWidth must be greater than zero");
        assert (kOutWidth > 0)
            else $fatal(1, "fxp_resize: kOutWidth must be greater than zero");
        assert ((kInFracBits >= 0) && (kInFracBits < kInWidth))
            else $fatal(1, "fxp_resize: kInFracBits must be in [0, kInWidth-1]");
        assert ((kOutFracBits >= 0) && (kOutFracBits < kOutWidth))
            else $fatal(1, "fxp_resize: kOutFracBits must be in [0, kOutWidth-1]");
    end

    // =========================================================================
    // Internal Signals -- all in working width
    // =========================================================================
    logic signed [kWorkWidth-1:0] data_ext;       // Sign-extended input
    logic signed [kWorkWidth-1:0] aligned_data;   // After fractional alignment shift
    logic signed [kWorkWidth-1:0] trunc_data;     // Truncated (floor) result -- baseline for rounding comparison
    logic signed [kWorkWidth-1:0] rounded_data;   // After rounding logic applied
    logic signed [kWorkWidth-1:0] max_out;        // Maximum representable value in output format
    logic signed [kWorkWidth-1:0] min_out;        // Minimum representable value in output format
    logic signed [kWorkWidth-1:0] lsb_half;       // Half the weight of the discarded LSB (= 2^(kFracDownshift-1))
    logic                         guard_bit;       // MSB of discarded bits (IEEE 754 guard)
    logic                         lsb_after_shift; // LSB of result after truncation (for convergent tie-break)
    logic                         sticky_bits;     // OR-reduction of remaining discarded bits (IEEE 754 sticky)

    // =========================================================================
    // Combinational Processing Pipeline
    // =========================================================================
    always_comb begin

        // ---------------------------------------------------------------------
        // Stage 1: Sign Extension
        // Replicate the input's sign bit to fill the working width.
        // Uses input[kInWidth-1] explicitly (rather than assuming 1'b0 for
        // positive) to correctly sign-extend negative values.
        // ---------------------------------------------------------------------
        data_ext = {{(kWorkWidth-kInWidth){data_in[kInWidth-1]}}, data_in};

        // ---------------------------------------------------------------------
        // Stage 2: Fractional Alignment
        // Upsize case:  kOutFracBits > kInFracBits  =>  left-shift, no precision loss
        // Downsize case: kInFracBits > kOutFracBits  =>  right-shift, rounding applies
        // Equal case:   no shift needed
        // ---------------------------------------------------------------------
        if (kFracUpshift > 0) begin
            aligned_data = data_ext <<< kFracUpshift;
        end else begin
            aligned_data = data_ext;
        end

        // ---------------------------------------------------------------------
        // Stage 3: Rounding (only when reducing fractional bits)
        // Default: pass aligned_data through unchanged (no rounding when upsize/equal)
        // ---------------------------------------------------------------------
        trunc_data   = aligned_data;
        rounded_data = aligned_data;
        rounded_up   = 1'b0;

        if (kFracDownshift > 0) begin

            // Baseline: simple truncation toward -infinity (floor)
            // SystemVerilog >>> performs arithmetic shift: sign bit fills from left
            trunc_data   = aligned_data >>> kFracDownshift;
            rounded_data = trunc_data;

            // --- Compute round-decision signals (IEEE 754 guard/sticky paradigm) ---

            // lsb_half = 2^(kFracDownshift-1), half the weight of the bit being discarded.
            // Constructed as: [zeros...][1][zeros...] with the '1' at position kFracDownshift-1.
            // $signed() is critical: without it, SystemVerilog treats the concat as unsigned,
            // which can break signed comparisons with aligned_data.
            lsb_half = $signed({ {(kWorkWidth-kFracDownshift){1'b0}}, 1'b1, {(kFracDownshift-1){1'b0}} });

            // guard_bit: the MSB of the bits being discarded (bit kFracDownshift-1 of aligned_data)
            guard_bit = aligned_data[kFracDownshift-1];

            // lsb_after_shift: LSB of the truncated result, used for convergent tie-breaking
            lsb_after_shift = trunc_data[0];

            // sticky_bits: OR-reduction of all discarded bits EXCEPT guard_bit.
            // If any of these bits is 1, the value is NOT an exact tie -- round up.
            sticky_bits = (kFracDownshift > 1) ? |aligned_data[kFracDownshift-2:0] : 1'b0;

            // --- Apply selected rounding mode ---
            case (kRoundMode)

                // ----------------------------------------------------------------
                // ROUND_TRUNCATE (floor):
                // Simply discard all fractional bits. Always rounds toward -infinity.
                //   +1.75 -> +1.0
                //   -1.75 -> -2.0
                // Zero logic cost. Introduces systematic negative bias (E[error] < 0).
                // ----------------------------------------------------------------
                ROUND_TRUNCATE: begin
                    rounded_data = trunc_data;
                end

                // ----------------------------------------------------------------
                // ROUND_NEAREST (half away from zero / "half-up"):
                // Add 0.5 LSB before truncation, with sign-dependent bias correction.
                //
                // For POSITIVE numbers:     add lsb_half          (= +0.5 LSB)
                //   +1.5 -> +2.0,  +1.25 -> +1.0
                //
                // For NEGATIVE numbers:     add lsb_half - 1      (= +0.5 LSB - 1 ULP)
                //   -1.5 -> -2.0,  -1.25 -> -1.0
                //
                // Why "lsb_half - 1" for negatives?
                // SystemVerilog >>> is an ARITHMETIC shift (rounds toward -infinity),
                // NOT a truncate-toward-zero shift. To achieve "half away from zero"
                // with a floor-based shift, negative values need bias = lsb_half - 1
                // instead of -lsb_half (which would be correct for truncate-toward-zero).
                //
                // Example (kFracDownshift=3, lsb_half=4):
                //   aligned = -1 (= -0.125 after shift)  ->  + (4-1)=+3 ->  2 -> >>3 -> 0  (correct)
                //   aligned = -5 (= -0.625 after shift)  ->  + (4-1)=+3 -> -2 -> >>3 -> -1 (correct)
                // ----------------------------------------------------------------
                ROUND_NEAREST: begin
                    if (aligned_data >= 0) begin
                        // Positive: standard half-up
                        rounded_data = (aligned_data + lsb_half) >>> kFracDownshift;
                    end else begin
                        // Negative: adjust bias for floor-based arithmetic shift
                        rounded_data = (aligned_data + lsb_half - 1) >>> kFracDownshift;
                    end
                end

                // ----------------------------------------------------------------
                // ROUND_CONVERGENT (banker's rounding / round-to-even):
                // Round to nearest, but TIES go to the nearest EVEN number.
                //
                // Decision logic:
                //   guard_bit == 0         -> round down (truncate)
                //   guard_bit == 1  AND
                //     (sticky_bits == 1)   -> NOT a tie -> round up
                //     (lsb_after_shift==1) -> odd result -> round up to even
                //   guard_bit == 1  AND
                //     (sticky_bits == 0)
                //     (lsb_after_shift==0) -> tie to even -> round down (already even)
                //
                // Examples:
                //   +1.5 -> +2.0  (odd +1, tie -> even +2)
                //   +2.5 -> +2.0  (even +2, tie -> stay +2)
                //   +1.25-> +1.0  (guard=0, no tie)
                //   -1.5 -> -2.0  (odd -1, tie -> even -2)
                //
                // Why convergent? Eliminates DC bias in repeated rounding.
                // IEEE 754 default. Essential for accumulators, integrators, AGC.
                // ----------------------------------------------------------------
                ROUND_CONVERGENT: begin
                    rounded_data = trunc_data;
                    if (guard_bit && (sticky_bits || lsb_after_shift)) begin
                        rounded_data = trunc_data + 1;
                    end
                end

                // --- Unknown rounding mode: falls back to truncate ---
                default: begin
                    rounded_data = trunc_data;
                end
            endcase

            // rounded_up flag: asserted whenever rounding increased the value
            rounded_up = (rounded_data != trunc_data);
        end

        // ---------------------------------------------------------------------
        // Stage 4: Saturation
        // Compare rounded result against output-format min/max bounds.
        // ---------------------------------------------------------------------

        // max_out = +2^(kOutWidth-1) - 1  =  {0, 0, 111...1}  in working width
        max_out = {{(kWorkWidth-kOutWidth){1'b0}}, 1'b0, {(kOutWidth-1){1'b1}}};

        // min_out = -2^(kOutWidth-1)      =  {1, 1, 000...0}  in working width
        // Two's complement: sign bit 1, all data bits 0
        min_out = {{(kWorkWidth-kOutWidth){1'b1}}, 1'b1, {(kOutWidth-1){1'b0}}};

        overflow  = (rounded_data > max_out) || (rounded_data < min_out);
        saturated = 1'b0;

        // --- Apply saturation clamping ---
        if (kEnableSaturation && (rounded_data > max_out)) begin
            // Positive overflow: clamp to maximum positive value
            // Example: +128 wraps to +127 in 8-bit
            data_out   = max_out[kOutWidth-1:0];
            saturated  = 1'b1;
        end else if (kEnableSaturation && (rounded_data < min_out)) begin
            // Negative overflow: clamp to minimum negative value
            // Example: -129 wraps to -128 in 8-bit
            data_out   = min_out[kOutWidth-1:0];
            saturated  = 1'b1;
        end else begin
            // No saturation needed, or saturation disabled: pass through lower bits
            data_out   = rounded_data[kOutWidth-1:0];
        end
    end

endmodule

`endif // FXP_RESIZE_SV
