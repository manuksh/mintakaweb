// ============================================================================
// File:         fir_polyphase.sv
// Project:      FPGA SDR IP Library
// Description:  Parameterized polyphase FIR filter engine for efficient
//               interpolation, decimation and filter-bank structures.
//
//               One coefficient phase is selected for each accepted input
//               sample. Tap 0 uses the current sample; remaining taps use the
//               registered sample history. The full-precision MAC result is
//               arithmetically scaled before it is narrowed to the output.
//
//               Architecture:
//                 1. AXI-Stream input acceptance and phase selection
//                 2. Tap-0 current sample plus delayed sample history
//                 3. Per-phase multiply-accumulate (MAC)
//                 4. Fixed-point scale and AXI-Stream output registration
//
//               Latency: 1 cycle from accepted input to valid output
//               Interfaces: AXI-Stream-style valid/ready data path
// ============================================================================
// Proprietary and Confidential
// Copyright (c) 2026 Mintaka LLC. All rights reserved.
// ============================================================================
// Author:        Mintaka Engineering Team
// Created:       2026-05-14
// Version:       1.0.0
// ============================================================================

`ifndef FIR_POLYPHASE_SV
`define FIR_POLYPHASE_SV

module fir_polyphase #(
    parameter int kDataWidth   = 16,
    parameter int kCoeffWidth  = 16,
    parameter int kNumPhases   = 4,
    parameter int kTapsPerPhase = 16,
    parameter int kAccWidth    = 48,
    // Number of fractional accumulator bits to discard after the MAC.
    // The default maps coefficients with kCoeffWidth-1 fractional bits back
    // to the input sample scale.
    parameter int kFracBitsToDrop = kCoeffWidth - 1,
    parameter logic signed [kCoeffWidth-1:0] kCoeffs [0:kNumPhases-1][0:kTapsPerPhase-1] = '{default:'{default:1}}
) (
    input  logic                               clk,
    input  logic                               rst_n,

    input  logic                               s_tvalid,
    output logic                               s_tready,
    input  logic signed [kDataWidth-1:0]       s_tdata,
    input  logic [((kNumPhases > 1) ? $clog2(kNumPhases) : 1)-1:0] s_tphase,
    input  logic                               s_tlast,

    output logic                               m_tvalid,
    input  logic                               m_tready,
    output logic signed [kDataWidth-1:0]       m_tdata,
    output logic [((kNumPhases > 1) ? $clog2(kNumPhases) : 1)-1:0] m_tphase,
    output logic                               m_tlast
);

    logic signed [kDataWidth-1:0] sample_reg [0:kTapsPerPhase-1];
    logic signed [kAccWidth-1:0]  mac_sum;
    logic signed [kAccWidth-1:0]  mac_scaled;
    logic                         accept_input;

    localparam int kRequiredAccWidth = kDataWidth + kCoeffWidth
                                     + ((kTapsPerPhase > 1) ? $clog2(kTapsPerPhase) : 0);
    localparam int kShift = (kFracBitsToDrop < 0) ? 0 : kFracBitsToDrop;

    // Catch invalid fixed-point and array configurations before simulation.
    initial begin
        assert (kDataWidth > 0) else $fatal(1, "fir_polyphase: kDataWidth must be greater than zero");
        assert (kCoeffWidth > 0) else $fatal(1, "fir_polyphase: kCoeffWidth must be greater than zero");
        assert (kNumPhases > 0) else $fatal(1, "fir_polyphase: kNumPhases must be greater than zero");
        assert (kTapsPerPhase > 0) else $fatal(1, "fir_polyphase: kTapsPerPhase must be greater than zero");
        assert (kFracBitsToDrop >= 0) else $fatal(1, "fir_polyphase: kFracBitsToDrop must not be negative");
        assert (kAccWidth >= kRequiredAccWidth)
            else $fatal(1, "fir_polyphase: kAccWidth is too small for the configured MAC");
    end

    assign s_tready = ~m_tvalid || m_tready;
    assign accept_input = s_tvalid && s_tready;

    always_comb begin
        mac_sum = '0;
        // Guard against unused binary phase encodings when kNumPhases is not
        // a power of two. This also prevents an out-of-range coefficient read.
        if (s_tphase < kNumPhases) begin
            for (int idx = 0; idx < kTapsPerPhase; idx++) begin
                // Tap 0 uses the current accepted sample. Each remaining tap
                // uses the appropriately delayed entry from the sample history.
                if (idx == 0) begin
                    mac_sum = mac_sum + ($signed(s_tdata) * $signed(kCoeffs[s_tphase][idx]));
                end else begin
                    mac_sum = mac_sum + ($signed(sample_reg[idx-1]) * $signed(kCoeffs[s_tphase][idx]));
                end
            end
        end
        // Arithmetic scaling restores the target fixed-point binary point.
        mac_scaled = mac_sum >>> kShift;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int idx = 0; idx < kTapsPerPhase; idx++) begin
                sample_reg[idx] <= '0;
            end
            m_tvalid  <= 1'b0;
            m_tdata   <= '0;
            m_tphase  <= '0;
            m_tlast   <= 1'b0;
        end else begin
            if (accept_input) begin
                for (int idx = kTapsPerPhase-1; idx > 0; idx--) begin
                    sample_reg[idx] <= sample_reg[idx-1];
                end
                sample_reg[0] <= s_tdata;

                m_tvalid <= 1'b1;
                m_tdata  <= mac_scaled[kDataWidth-1:0];
                m_tphase <= s_tphase;
                m_tlast  <= s_tlast;
            end else if (m_tvalid && m_tready) begin
                m_tvalid <= 1'b0;
            end
        end
    end

endmodule

`endif // FIR_POLYPHASE_SV
