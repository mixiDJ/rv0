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
// Name: sync.sv
// Auth: Nikola Lukić
// Date: 21.08.2024.
// Desc: Configurable multi-bit synchronizer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module sync #(
    parameter int unsigned           DATA_WIDTH = 1,
    parameter int unsigned           SYNC_DEPTH = 2,
    parameter logic [DATA_WIDTH-1:0] RST_VAL    = {DATA_WIDTH{1'b0}}
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic [DATA_WIDTH-1:0]   sig_i,
    output logic [DATA_WIDTH-1:0]   sync_o

);

    logic [DATA_WIDTH-1:0] sync_meta_q [0:SYNC_DEPTH-1];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sync_meta_q[SYNC_DEPTH-1] <= RST_VAL;
        else sync_meta_q[SYNC_DEPTH-1] <= sig_i;
    end

    for(genvar i = 0; i < SYNC_DEPTH - 1; ++i) begin
        always @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) sync_meta_q[i] <= RST_VAL;
            else sync_meta_q[i] <= sync_meta_q[i+1];
        end
    end

    assign sync_o = sync_meta_q[0];


    /*
     * FORMAL SVA
     */

`ifdef FORMAL

    `ASSERT(sva_sync_depth, sync_o == $past(sig_i, SYNC_DEPTH))

`endif // FORMAL

endmodule : sync
