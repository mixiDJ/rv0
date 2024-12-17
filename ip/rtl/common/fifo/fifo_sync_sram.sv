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
// Name: fifo_sync_sram.sv
// Auth: Nikola Lukić
// Date: 24.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo_sync_sram #(
    // fifo entry count
    parameter int unsigned FIFO_DEPTH    = 16,
    // fifo data width
    parameter int unsigned DATA_WIDTH    = 32,
    // overrun mode, 0 = overrun all; 1 = overrun first
    parameter bit          OVERRUN_MODE  = 0,
    // underrun mode, 0 = no underrun protection; 1 = underrun protection
    parameter bit          UNDERRUN_MODE = 0
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic                    we_i,
    input  logic [DATA_WIDTH-1:0]   wdata_i,
    output logic                    full_o,

    input  logic                    re_i,
    output logic [DATA_WIDTH-1:0]   rdata_o,
    output logic                    empty_o

);

    localparam int unsigned ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic [ADDR_WIDTH:0] ri_q;
    logic [ADDR_WIDTH-1:0] raddr;
    assign raddr = ri_q[ADDR_WIDTH-1:0];

    logic [ADDR_WIDTH:0] wi_q;
    logic [ADDR_WIDTH-1:0] waddr;
    assign waddr = wi_q[ADDR_WIDTH-1:0];


    /*
     * WRITE INDEX LOGIC
     */

    if(OVERRUN_MODE == 0) begin
        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) wi_q <= {ADDR_WIDTH+1{1'b0}};
            else if(we_i == 1'b1) wi_q <= wi_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end
    else begin
        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) wi_q <= {ADDR_WIDTH+1{1'b0}};
            else if(we_i == 1'b1 && full_o == 1'b0) wi_q <= wi_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end


    /*
     * READ INDEX LOGIC
     */

    if(UNDERRUN_MODE == 0) begin
        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ri_q <= {ADDR_WIDTH+1{1'b0}};
            else if(re_i == 1'b1) ri_q <= ri_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end
    else begin
        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ri_q <= {ADDR_WIDTH+1{1'b0}};
            else if(re_i == 1'b1 && empty_o == 1'b0) ri_q <= ri_q + {{ADDR_WIDTH{1'b0}}, 1'b1};
        end
    end


    /*
     * FIFO SRAM BLOCK
     */

    sram_sync_dp #(
        .SRAM_SIZE  (FIFO_DEPTH ),
        .DATA_WIDTH (DATA_WIDTH )
    )
    u_sram (
        .clk_i      (clk_i      ),
        .we_i       (we_i       ),
        .waddr_i    (waddr      ),
        .wdata_i    (wdata_i    ),
        .re_i       (re_i       ),
        .raddr_i    (raddr      ),
        .rdata_o    (rdata_o    )
    );


    /*
     * FIFO STATUS SIGNALS
     */

    assign full_o = (ri_q[ADDR_WIDTH] != wi_q[ADDR_WIDTH]) &&
                    (ri_q[ADDR_WIDTH-1:0] == wi_q[ADDR_WIDTH-1:0]);
    assign empty_o = ri_q == wi_q;

endmodule : fifo_sync_sram
