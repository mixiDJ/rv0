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
// Name: fifo_async.sv
// Auth: Nikola Lukić
// Date: 21.08.2024.
// Desc: Asynchronous FIFO
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo_async #(
    // fifo entry count
    parameter int unsigned  FIFO_DEPTH = 16,
    // fifo data width
    parameter int unsigned  DATA_WIDTH = 32
) (

    input  logic                    wclk_i,
    input  logic                    wrst_ni,

    input  logic                    rclk_i,
    input  logic                    rrst_ni,

    input  logic                    we_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic                    full_o,

    input  logic                    re_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    output logic                    empty_o

);

    localparam int unsigned ADDR_WIDTH = $clog2(FIFO_DEPTH);
    logic [DATA_WIDTH-1:0] fifo_data_q [0:FIFO_DEPTH-1];


    /*
     * FIFO READ INDEX LOGIC
     */

    logic [ADDR_WIDTH:0] ri_q;
    logic [ADDR_WIDTH-1:0] ri;
    assign ri = ri_q[ADDR_WIDTH-1:0];

    always_ff @(posedge rclk_i or negedge rrst_ni) begin
        if(rrst_ni == 1'b0) ri_q <= {ADDR_WIDTH+1{1'b0}};
        else if(re_i == 1'b1) ri_q <= ri_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
    end


    /*
     * READ INDEX SYNCRHONIZATION
     */

    logic [ADDR_WIDTH:0] ri_gray;
    logic [ADDR_WIDTH:0] ri_sync;

    conv_bin_gray #(ADDR_WIDTH+1)
    u_ri_conv (ri_q, ri_gray);

    sync #(ADDR_WIDTH+1)
    u_ri_sync (
        .clk_i  (wclk_i     ),
        .rst_ni (wrst_ni    ),
        .sig_i  (ri_gray    ),
        .sync_o (ri_sync    )
    );


    /*
     * FIFO WRITE INDEX LOGIC
     */

    logic [ADDR_WIDTH:0] wi_q;
    logic [ADDR_WIDTH-1:0] wi;
    assign wi = wi_q[ADDR_WIDTH-1:0];

    always_ff @(posedge wclk_i or negedge wrst_ni) begin
        if(wrst_ni == 1'b0) wi_q <= {ADDR_WIDTH+1{1'b0}};
        else if(we_i == 1'b1) wi_q <= wi_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
    end


    /*
     * WRITE INDEX SYNCRHONIZATION
     */

    logic [ADDR_WIDTH:0] wi_gray;
    logic [ADDR_WIDTH:0] wi_sync;

    conv_bin_gray #(ADDR_WIDTH+1)
    u_wi_conv (wi_q, wi_gray);

    sync #(ADDR_WIDTH+1)
    u_wi_sync (
        .clk_i  (rclk_i     ),
        .rst_ni (rrst_ni    ),
        .sig_i  (wi_gray    ),
        .sync_o (wi_sync    )
    );


    /*
     * FIFO WRITE DATA LOGIC
     */

    always_ff @(posedge wclk_i) begin
        if(we_i == 1'b1) fifo_data_q[wi] <= wdata_i;
    end


    /*
     * FIFO READ DATA LOGIC
     */

    assign rdata_o = fifo_data_q[ri];


    /*
     * FIFO STATUS SIGNAL LOGIC
     */

    assign full_o = ri_sync[ADDR_WIDTH-:2] == ~wi_gray[ADDR_WIDTH-:2] &&
                    ri_sync[ADDR_WIDTH-2:0] == wi_gray[ADDR_WIDTH-2:0];
    assign empty_o = ri_gray == wi_sync;


    /*
     * FORMAL SVA
     */

`ifdef FORMAL

    `COVER(sva_fifo_full, full_o == 1'b1 && $past(full_o) == 1'b0, wclk_i, wrst_ni)
    `COVER(sva_fifo_empty, empty_o == 1'b1 && $past(empty_o) == 1'b0, rclk_i, rrst_ni)

    `ASSUME(sva_fifo_overrun, full_o == 1'b0 || we_i == 1'b0, wclk_i, wrst_ni)
    `ASSUME(sva_fifo_underrun, empty_o == 1'b0 || re_i == 1'b0, rclk_i, rrst_ni)

    `ASSUME_INIT(sva_rrst_init, rrst_ni == 1'b0)
    `ASSUME_INIT(sva_wrst_init, wrst_ni == 1'b0)

    `ASSUME_I(sva_rst_sync, rrst_ni == wrst_ni)

    `ASSERT(sva_wi_gray_onehot, $onehot0(wi_gray ^ $past(wi_gray)), wclk_i, wrst_ni)
    `ASSERT(sva_ri_gray_onehot, $onehot0(ri_gray ^ $past(ri_gray)), rclk_i, rrst_ni)

`endif // FORMAL

endmodule : fifo_async
