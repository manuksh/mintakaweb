// ============================================================================
// File:         complex_mult.sv
// Project:      FPGA SDR IP Library
// Description:  Complex multiply: (a_re + j*a_im) * (b_re + j*b_im).
//
//               Implements the standard complex product:
//                 y_re = a_re*b_re - a_im*b_im
//                 y_im = a_re*b_im + a_im*b_re
//
//               The four products are evaluated at full precision. Their
//               real and imaginary sums are then arithmetically right-shifted
//               to restore the target fixed-point format. Each output component
//               has independent overflow reporting and optional saturation.
//
//               Latency: 0 cycles (purely combinational)
//               Use cases: frequency translation, complex mixing, phase
//                          rotation, channel equalization and I/Q processing.
// ============================================================================
// This material contains proprietary and confidential information which is the
// property of Mintaka LLC. No part of this material may be reproduced, stored,
// or transmitted in any form or by any means without the prior written
// authorization of Mintaka LLC.
//
// RESTRICTED RIGHTS LEGEND
// Use, duplication, or disclosure by the Government is subject to restrictions
// as set forth in subparagraph (c)(1)(ii) of the Rights in Technical Data and
// Computer Software clause at DFARS 252.227-7013 or subparagraphs (c)(1) and
// (2) of the Commercial Computer Software - Restricted Rights at 48 CFR 52.227-19
// Copyright (c) 2026 Mintaka LLC, All Rights Reserved.
// ============================================================================
// Author:        Mintaka Engineering Team
// Created:       2026-05-14
// Version:       1.0.0
// ============================================================================

`ifndef COMPLEX_MULT_SV
`define COMPLEX_MULT_SV

module complex_mult
    import sdr_types_pkg::*;
    import sdr_params_pkg::*;
#(
    // Width of every signed real/imaginary input component.
    parameter int kDataWidth         = 16,

    // Width of each signed real/imaginary output component after scaling.
    parameter int kOutWidth          = 16,

    // Number of LSBs discarded from the full-precision product sum.
    // For two inputs with 15 fractional bits, use 15 to align the result with
    // an output format that also has 15 fractional bits.
    parameter int kFracBitsToDrop    = 15,

    // When set, clamp out-of-range results instead of allowing wraparound.
    parameter bit kEnableSaturation  = 1'b1
) (
    // First complex input: a = a_re + j*a_im.
    input  logic signed [kDataWidth-1:0] a_re,
    input  logic signed [kDataWidth-1:0] a_im,

    // Second complex input: b = b_re + j*b_im.
    input  logic signed [kDataWidth-1:0] b_re,
    input  logic signed [kDataWidth-1:0] b_im,

    // Complex result: y = y_re + j*y_im.
    output logic signed [kOutWidth-1:0]  y_re,
    output logic signed [kOutWidth-1:0]  y_im,

    // Asserted when the scaled component is outside the output range,
    // regardless of whether saturation is enabled.
    output logic                         overflow_re,
    output logic                         overflow_im,

    // Asserted only when saturation is enabled and clamping is applied.
    output logic                         saturated_re,
    output logic                         saturated_im
);

    // A signed kDataWidth-by-kDataWidth multiplication produces 2*kDataWidth
    // bits. One additional bit is required when adding or subtracting products.
    localparam int kProdWidth = 2 * kDataWidth;
    localparam int kSumWidth  = kProdWidth + 1;

    // Negative values are treated as zero shift. The datapath uses an
    // arithmetic shift so signed values retain their sign during scaling.
    localparam int kShift     = (kFracBitsToDrop < 0) ? 0 : kFracBitsToDrop;

    // Signed output bounds used for overflow comparison and saturation.
    localparam logic signed [kOutWidth-1:0] kMaxVal = {1'b0, {(kOutWidth-1){1'b1}}};
    localparam logic signed [kOutWidth-1:0] kMinVal = {1'b1, {(kOutWidth-1){1'b0}}};

    // Four full-precision terms required by complex multiplication.
    logic signed [kProdWidth-1:0] ac;
    logic signed [kProdWidth-1:0] bd;
    logic signed [kProdWidth-1:0] ad;
    logic signed [kProdWidth-1:0] bc;

    // Full-precision and scaled real/imaginary results. max_ext and min_ext
    // are the output bounds sign-extended to the sum width for signed compares.
    logic signed [kSumWidth-1:0]  re_full;
    logic signed [kSumWidth-1:0]  im_full;
    logic signed [kSumWidth-1:0]  re_scaled;
    logic signed [kSumWidth-1:0]  im_scaled;
    logic signed [kSumWidth-1:0]  max_ext;
    logic signed [kSumWidth-1:0]  min_ext;

    always_comb begin
        // Stage 1: form all four signed products.
        ac = a_re * b_re;
        bd = a_im * b_im;
        ad = a_re * b_im;
        bc = a_im * b_re;

        // Stage 2: reconstruct the complex product. Explicit sign extension
        // preserves the carry bit during the add/subtract operations.
        re_full = $signed({ac[kProdWidth-1], ac}) - $signed({bd[kProdWidth-1], bd});
        im_full = $signed({ad[kProdWidth-1], ad}) + $signed({bc[kProdWidth-1], bc});

        // Stage 3: restore the requested fractional precision. This module
        // truncates discarded bits; rounding is handled by dedicated SDR-LIB IP.
        re_scaled = re_full >>> kShift;
        im_scaled = im_full >>> kShift;

        // Stage 4: compare each scaled component against the signed output
        // range before narrowing it to kOutWidth.
        max_ext = {{(kSumWidth-kOutWidth){kMaxVal[kOutWidth-1]}}, kMaxVal};
        min_ext = {{(kSumWidth-kOutWidth){kMinVal[kOutWidth-1]}}, kMinVal};

        overflow_re  = (re_scaled > max_ext) || (re_scaled < min_ext);
        overflow_im  = (im_scaled > max_ext) || (im_scaled < min_ext);
        saturated_re = 1'b0;
        saturated_im = 1'b0;

        // Apply saturation (or keep the low kOutWidth bits when disabled) to
        // the real component.
        if (kEnableSaturation && (re_scaled > max_ext)) begin
            y_re = kMaxVal;
            saturated_re = 1'b1;
        end else if (kEnableSaturation && (re_scaled < min_ext)) begin
            y_re = kMinVal;
            saturated_re = 1'b1;
        end else begin
            y_re = re_scaled[kOutWidth-1:0];
        end

        // Apply the same independent saturation policy to the imaginary
        // component.
        if (kEnableSaturation && (im_scaled > max_ext)) begin
            y_im = kMaxVal;
            saturated_im = 1'b1;
        end else if (kEnableSaturation && (im_scaled < min_ext)) begin
            y_im = kMinVal;
            saturated_im = 1'b1;
        end else begin
            y_im = im_scaled[kOutWidth-1:0];
        end
    end

endmodule

`endif // COMPLEX_MULT_SV
