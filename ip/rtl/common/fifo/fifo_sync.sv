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
// Name: fifo_sync.sv
// Auth: Nikola Lukić (luk)
// Date: 21.08.2024.
// Desc: Synchronous FIFO with sync clear & async reset
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo_sync #(
    // fifo entry count
    parameter int unsigned  FIFO_DEPTH = 16,
    // fifo data width
    parameter int unsigned  DATA_WIDTH = 32,
    // asynchronous fifo data clear (rst_ni)
    parameter bit           DATA_RESET = 0,
    // synchronous read/write index clear (clr_i)
    parameter bit           SYNC_CLEAR = 1,
    // synchronous fifo data clear (clr_i)
    parameter bit           DATA_CLEAR = 0
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,
    input  logic                    clr_i,

    input  logic                    we_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic                    full_o,

    input  logic                    re_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    output logic                    empty_o

);


    localparam int unsigned ADDR_WIDTH = $clog2(FIFO_DEPTH);
    logic [DATA_WIDTH-1:0] fifo_data_q [0:FIFO_DEPTH-1];

    logic [ADDR_WIDTH:0] ri_q;
    logic [ADDR_WIDTH-1:0] ri;
    assign ri = ri_q[ADDR_WIDTH-1:0];

    logic [ADDR_WIDTH:0] wi_q;
    logic [ADDR_WIDTH-1:0] wi;
    assign wi = wi_q[ADDR_WIDTH-1:0];


    /*
     * FIFO READ INDEX LOGIC
     */

    if(SYNC_CLEAR == 1'b1) begin : ri_sync_clr_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ri_q <= {ADDR_WIDTH+1{1'b0}};
            else begin
                if(clr_i == 1'b1) ri_q <= {ADDR_WIDTH+1{1'b0}};
                else if(re_i == 1'b1) ri_q <= ri_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

    end // ri_sync_clr_genblk
    else begin : ri_sync_nclr_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ri_q <= {ADDR_WIDTH+1{1'b0}};
            else if(re_i == 1'b1) ri_q <= ri_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end

    end // ri_sync_nclr_genblk


    /*
     * FIFO WRITE INDEX LOGIC
     */

    if(SYNC_CLEAR == 1'b1) begin : wi_sync_clear_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) wi_q <= {ADDR_WIDTH+1{1'b0}};
            else begin
                if(clr_i == 1'b1) wi_q <= {ADDR_WIDTH+1{1'b0}};
                else if(we_i == 1'b1) wi_q <= wi_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
            end
        end

    end // wi_sync_clear_genblk
    else begin : wi_sync_nclr_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) wi_q <= {ADDR_WIDTH+1{1'b0}};
            else if(we_i == 1'b1) wi_q <= wi_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end

    end // wi_sync_nclr_genblk


    /*
     * FIFO WRITE DATA LOGIC
     */

    if(DATA_RESET == 1'b1 && SYNC_CLEAR == 1'b1) begin : fifo_data_rst_clr_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) begin
                for(int i = 0; i < FIFO_DEPTH; ++i) begin
                    fifo_data_q[i] <= {DATA_WIDTH{1'b0}};
                end
            end
            else begin
                if(clr_i == 1'b1) begin
                    for(int i = 0; i < FIFO_DEPTH; ++i) begin
                        fifo_data_q[i] <= {DATA_WIDTH{1'b0}};
                    end
                end
                else if(we_i == 1'b1) fifo_data_q[wi] <= wdata_i;
            end
        end

    end // fifo_data_rst_clr_genblk
    else if(DATA_RESET == 1'b1) begin : fifo_data_rst_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) begin
                for(int i = 0; i < FIFO_DEPTH; ++i) begin
                    fifo_data_q[i] <= {DATA_WIDTH{1'b0}};
                end
            end
            else if(we_i == 1'b1) fifo_data_q[wi] <= wdata_i;
        end

    end // fifo_data_rst_genblk
    else if(SYNC_CLEAR == 1'b1) begin : fifo_data_clr_genblk

        always_ff @(posedge clk_i) begin
            if(clr_i == 1'b1) begin
                for(int i = 0; i < FIFO_DEPTH; ++i) begin
                    fifo_data_q[i] <= {DATA_WIDTH{1'b0}};
                end
            end
            else if(we_i == 1'b1) fifo_data_q[wi] <= wdata_i;
        end

    end // fifo_data_clk_genblk
    else begin : fifo_data_nrst_genblk

        always_ff @(posedge clk_i) begin
            if(we_i == 1'b1) fifo_data_q[wi] <= wdata_i;
        end

    end // fifo_data_nrst_genblk


    /*
     * FIFO READ DATA LOGIC
     */

    assign rdata_o = fifo_data_q[ri];


    /*
     * FIFO STATUS SIGNALS
     */

    assign full_o = (ri_q[ADDR_WIDTH] != wi_q[ADDR_WIDTH]) &&
                    (ri_q[ADDR_WIDTH-1:0] == wi_q[ADDR_WIDTH-1:0]);
    assign empty_o = ri_q == wi_q;


    /*
     * FORMAL SVA
     */

`ifdef FORMAL

    `COVER(sva_fifo_full,  full_o == 1'b1  && $past(full_o) == 1'b0)
    `COVER(sva_fifo_empty, empty_o == 1'b1 && $past(empty_o) == 1'b0)
    `COVER(sva_fifo_clear, clr_i == 1'b1   && $past(empty_o) == 1'b0)

    `ASSUME(sva_fifo_overrun,  full_o == 1'b0  || we_i == 1'b0)
    `ASSUME(sva_fifo_underrun, empty_o == 1'b0 || re_i == 1'b0)

    `ASSERT(sva_fifo_reset_valid, empty_o == 1'b1 || $past(rst_ni) == 1'b1)
    `ASSERT(sva_fifo_clear_valid, empty_o == 1'b1 || $past(clr_i) == 1'b0)

    `ASSUME_INIT(sva_rst_init, rst_ni == 1'b0)

`endif // FORMAL

endmodule : fifo_sync
