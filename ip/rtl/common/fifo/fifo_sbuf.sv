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
// Name: fifo_sbuf.sv
// Auth: Nikola Lukić
// Date: 13.11.2024.
// Desc: Skid-buffer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo_sbuf #(
    parameter int unsigned          DATA_WIDTH = 32,
    parameter bit [DATA_WIDTH-1:0]  RST_VAL    = {DATA_WIDTH{1'b0}}
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic [DATA_WIDTH-1:0]   data_i,
    input  logic                    rdy_i,
    output logic                    ack_o,

    output logic [DATA_WIDTH-1:0]   data_o,
    output logic                    rdy_o,
    input  logic                    ack_i

);

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) rdy_o <= 1'b0;
        else begin
            if(ack_i == 1'b1) rdy_o <= 1'b0;
            if(rdy_i == 1'b1) rdy_o <= 1'b1;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) data_o <= RST_VAL;
        else begin
            if(rdy_i == 1'b1 && rdy_o == 1'b0) data_o <= data_i;
            if(rdy_i == 1'b1 && ack_i == 1'b1) data_o <= data_i;
        end
    end

    assign ack_o = rdy_o == 1'b0 || ack_i == 1'b1;

endmodule : fifo_sbuf
