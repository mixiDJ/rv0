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
// Name: arbt_rr.sv
// Auth: Nikola Lukić (luk)
// Date: 07.09.2024.
// Desc: Round-robin arbiter
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`include "sva_utils.svh"

module arbt_rr #(
    parameter int unsigned          DATA_WIDTH = 32,
    parameter int unsigned          ARBT_WIDTH = 4,
    parameter bit [DATA_WIDTH-1:0]  RESET_VAL  = {DATA_WIDTH{1'b0}}
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic [DATA_WIDTH-1:0]   data_i [0:ARBT_WIDTH-1],
    input  logic                    req_i  [0:ARBT_WIDTH-1],
    output logic                    gnt_o  [0:ARBT_WIDTH-1],

    output logic [DATA_WIDTH-1:0]   data_o,
    output logic                    rdy_o,
    input  logic                    ack_i

);

    /*
     * ARBITER INDEX LOGIC
     */

    localparam int unsigned ADDR_WIDTH = $clog2(ARBT_WIDTH);
    logic [ADDR_WIDTH-1:0] arbt_idx;
    logic [ADDR_WIDTH-1:0] arbt_cur_idx_q;

    // standard round-robin index generation
    // arbiter will give lowest priority to
    // previously granted requester
    always_comb begin
        arbt_idx = {ADDR_WIDTH{1'b0}};
        for(int i = arbt_cur_idx_q; i >= 0; --i) begin
            if(req_i[i] == 1'b1) arbt_idx = i;
        end
        for(int i = ARBT_WIDTH - 1; i > arbt_cur_idx_q; --i) begin
            if(req_i[i] == 1'b1) arbt_idx = i;
        end
    end


    /*
     * ARBITER PENDING REQUEST LOGIC
     */

    logic arbt_pend_q;
    logic arbt_pend_d;

    logic arbt_gnt_ena;

    always_comb begin
        arbt_pend_d = arbt_pend_q;
        arbt_gnt_ena = 1'b0;

        if(arbt_pend_q == 1'b1 && ack_i == 1'b1) arbt_pend_d = 1'b0;

        for(int i = 0; i < ARBT_WIDTH; ++i) begin
            if(arbt_pend_d == 1'b0 && req_i[i] == 1'b1) begin
                arbt_pend_d = 1'b1;
                arbt_gnt_ena = 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) arbt_pend_q <= 1'b0;
        else arbt_pend_q <= arbt_pend_d;
    end


    /*
     * ARBITER CURRENT INDEX LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) arbt_cur_idx_q <= {ADDR_WIDTH{1'b1}};
        else if(arbt_gnt_ena) arbt_cur_idx_q <= arbt_idx;
    end


    /*
     * ARBITER GRANT LOGIC
     */

    logic arbt_gnt_q [0:ARBT_WIDTH-1];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) begin
            for(int i = 0; i < ARBT_WIDTH; ++i) begin
                gnt_o[i] <= 1'b0;
            end
        end
        else begin
            for(int i = 0; i < ARBT_WIDTH; ++i) begin
                gnt_o[i] <= arbt_gnt_ena == 1'b1 && arbt_idx == i;
            end
        end
    end


    /*
     * ARBITER DATA LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) begin
            data_o <= RESET_VAL;
        end
        else begin
            if(arbt_gnt_ena == 1'b1) begin
                data_o <= data_i[arbt_idx];
            end
        end
    end


    /*
     * ARBITER READY LOGIC
     */

    assign rdy_o = arbt_pend_q;


    /*
     * SVA
     */

    `ASSERT_INIT(chk_arbt_width, $onehot(ARBT_WIDTH))
    `ASSERT(chk_gnt_onehot, $onehot0(gnt_o))
    `ASSERT(chk_req_rdy_seq, rdy_o == $past(req_i.or()))


    /*
     * FORMAL SVA
     */

`ifdef FORMAL

`endif // FORMAL

endmodule : arbt_rr
