////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2024  Nikola Lukić <lukicn@protonmail.com>
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2
//
// You may redistribute and modify this documentation and make products
// using it under the terms of the CERN-OHL-S v2 (https:/cern.ch/cern-ohl).
// This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
// AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-S v2
// for applicable conditions.
//
// Source location: svn://lukic.sytes.net/ip
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: clk_follow.sv
// Auth: Nikola Lukić
// Date: 13.09.2024.
// Desc: Clock follower circuit for crossing from SDR to DDR domain
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module clk_follow (

    // single data rate clock domain
    input  logic    clk_sdr_i,
    input  logic    rst_sdr_ni,

    // double data rate clock domain
    input  logic    clk_ddr_i,

    // single data rate clock follower signal
    output logic    clk_follow_o

);

    logic tff_q;

    always_ff @(posedge clk_sdr_i or negedge rst_sdr_ni) begin
        if(rst_sdr_ni == 1'b0) tff_q <= 1'b0;
        else tff_q <= ~tff_q;
    end

    logic dff_q;

    always_ff @(posedge clk_ddr_i) begin
        dff_q <= tff_q;
        clk_follow_o <= ~(tff_q ^ dff_q);
    end

endmodule : clk_follow
