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
// Source location:
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: uart_bclk_gen.sv
// Auth: Nikola Lukić
// Date: 21.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_bclk_gen (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [15:0] uartibrd_i,
    input  logic [ 5:0] uartfbrd_i,
    output logic        bclk_tick_o
);

    logic [15:0] bclk_cnt_q;
    logic [15:0] bclk_cnt_d;

    always_comb begin
        bclk_cnt_d = bclk_cnt_q + 16'h1;
        if(bclk_cnt_q == uartibrd_i - 16'h1) bclk_cnt_d = 16'h0;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) bclk_cnt_q <= 16'h0;
        else bclk_cnt_q <= bclk_cnt_d;
    end

    assign bclk_tick_o = bclk_cnt_q == uartibrd_i - 16'h1;

endmodule : uart_bclk_gen
