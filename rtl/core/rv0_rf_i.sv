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
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_rf_i.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc: Integer register file
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_rf_i #(`RV0_CORE_PARAM_LST) (

    input  logic                clk_i,
    input  logic                rst_ni,

    input  logic [4:0]          raddr1_i,
    output logic [XLEN-1:0]     rdata1_o,

    input  logic [4:0]          raddr2_i,
    output logic [XLEN-1:0]     rdata2_o,

    input  logic [4:0]          waddr_i,
    input  logic [XLEN-1:0]     wdata_i,
    input  logic                we_i

);

    localparam int unsigned REG_CNT = RVI ? 32 : 16;

    logic [XLEN-1:0] reg_out [0:REG_CNT-1];
    assign reg_out[0] = {XLEN{1'b0}};

    for(genvar i = 1; i < REG_CNT; ++i) begin : rf_i_genblk

        logic [XLEN-1:0] reg_q;

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) reg_q <= {XLEN{1'b0}};
            else if(we_i == 1'b1 && waddr_i == i) reg_q <= wdata_i;
        end

        assign reg_out[i] = reg_q;

    end // rf_i_genblk

    assign rdata1_o = reg_out[raddr1_i];
    assign rdata2_o = reg_out[raddr2_i];

endmodule : rv0_rf_i
