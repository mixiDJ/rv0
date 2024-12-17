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
// Name: uart_apb_top.sv
// Auth: Nikola Lukić
// Date: 20.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_apb_top #(
    parameter  int unsigned         ADDR_WIDTH      = 32,
    parameter  int unsigned         DATA_WIDTH      = 32,
    parameter  int unsigned         USER_REQ_WIDTH  = 0,
    parameter  int unsigned         USER_DATA_WIDTH = 0,
    parameter  int unsigned         USER_RESP_WIDTH = 0,
    localparam int unsigned         STRB_WIDTH      = DATA_WIDTH/8,
    parameter  bit [ADDR_WIDTH-1:0] UART_ADDR_BASE  = 'h1600_0000,
    parameter  bit [ADDR_WIDTH-1:0] UART_ADDR_MASK  = 'hfff
) (

    /* APB INTERFACE */
    input  logic                        pclk_i,
    input  logic                        prst_ni,
    input  logic [ADDR_WIDTH-1:0]       paddr_i,
    input  logic [3:0]                  pprot_i,
    input  logic                        pnse_i,
    input  logic                        psel_i,
    input  logic                        penable_i,
    input  logic                        pwrite_i,
    input  logic [DATA_WIDTH-1:0]       pwdata_i,
    input  logic [STRB_WIDTH-1:0]       pstrb_i,
    output logic                        pready_o,
    output logic [DATA_WIDTH-1:0]       prdata_o,
    output logic                        pslverr_o,
    input  logic                        pwakeup_i,
    input  logic [USER_REQ_WIDTH-1:0]   pauser_i,
    input  logic [USER_DATA_WIDTH-1:0]  pwuser_i,
    output logic [USER_DATA_WIDTH-1:0]  pruser_o,
    output logic [USER_RESP_WIDTH-1:0]  pbuser_o,

    /* INTERRUPT SIGNAL */
    output logic                        irq_o,

    /* UART INTERFACE */
    input  logic                        uart_rx_i,
    output logic                        uart_tx_o,

    input  logic                        uart_ri_ni,
    input  logic                        uart_cts_ni,
    input  logic                        uart_dsr_ni,
    input  logic                        uart_dcd_ni,
    output logic                        uart_dtr_no,
    output logic                        uart_rts_no,
    output logic                        uart_out1_no,
    output logic                        uart_out2_no

);

    logic           reg_access;
    logic [11:0]    reg_addr;
    logic           reg_we;
    logic [15:0]    reg_wdata;
    logic [15:0]    reg_rdata;

    uart_apb_if #(
        .ADDR_WIDTH         (ADDR_WIDTH         ),
        .DATA_WIDTH         (DATA_WIDTH         ),
        .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),
        .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),
        .USER_RESP_WIDTH    (USER_RESP_WIDTH    ),
        .UART_ADDR_BASE     (UART_ADDR_BASE     ),
        .UART_ADDR_MASK     (UART_ADDR_MASK     )
    )
    u_if (
        .pclk_i             (pclk_i             ),
        .prst_ni            (prst_ni            ),
        .paddr_i            (paddr_i            ),
        .pprot_i            (pprot_i            ),
        .pnse_i             (pnse_i             ),
        .psel_i             (psel_i             ),
        .penable_i          (penable_i          ),
        .pwrite_i           (pwrite_i           ),
        .pwdata_i           (pwdata_i           ),
        .pstrb_i            (pstrb_i            ),
        .pready_o           (pready_o           ),
        .prdata_o           (prdata_o           ),
        .pslverr_o          (pslverr_o          ),
        .pwakeup_i          (pwakeup_i          ),
        .pauser_i           (pauser_i           ),
        .pwuser_i           (pwuser_i           ),
        .pruser_o           (pruser_i           ),
        .pbuser_o           (pbuser_o           ),

        .reg_access_o       (reg_access         ),
        .reg_addr_o         (reg_addr           ),
        .reg_we_o           (reg_we             ),
        .reg_wdata_o        (reg_wdata          ),
        .reg_rdata_i        (reg_rdata          )
    );

    logic uart_clk;
    assign uart_clk = pclk_i;
    logic uart_rst_n;
    assign uart_rst_n = prst_ni;

    logic [11:0]    rx_data;
    logic           rx_re;
    logic [ 7:0]    tx_data;
    logic           tx_we;

    logic [15:0]    uartibrd;
    logic [ 5:0]    uartfbrd;

    logic           lcr_sps;
    logic [ 1:0]    lcr_wlen;
    logic           lcr_fen;
    logic           lcr_stp2;
    logic           lcr_eps;
    logic           lcr_pen;
    logic           lcr_brk;

    logic           cr_ctsen;
    logic           cr_rtsen;
    logic           cr_out2;
    logic           cr_out1;
    logic           cr_rts;
    logic           cr_dtr;
    logic           cr_rxe;
    logic           cr_txe;
    logic           cr_lbe;
    logic           cr_sirlp;
    logic           cr_siren;
    logic           cr_uarten;

    uart_reg
    u_reg (
        .clk_i              (pclk_i             ),
        .rst_ni             (prst_ni            ),

        .reg_access_i       (reg_access         ),
        .reg_addr_i         (reg_addr           ),
        .reg_we_i           (reg_we             ),
        .reg_wdata_i        (reg_wdata          ),
        .reg_rdata_o        (reg_rdata          ),

        .rx_data_i          (rx_data            ),
        .rx_re_o            (rx_re              ),
        .tx_data_o          (tx_data            ),
        .tx_we_o            (tx_we              ),

        .uartibrd_o         (uartibrd           ),
        .uartfbrd_o         (uartfbrd           ),

        .lcr_sps_o          (lcr_sps            ),
        .lcr_wlen_o         (lcr_wlen           ),
        .lcr_fen_o          (lcr_fen            ),
        .lcr_stp2_o         (lcr_stp2           ),
        .lcr_eps_o          (lcr_eps            ),
        .lcr_pen_o          (lcr_pen            ),
        .lcr_brk_o          (lcr_brk            ),

        .cr_ctsen_o         (cr_ctsen           ),
        .cr_rtsen_o         (cr_rtsen           ),
        .cr_out2_o          (cr_out2            ),
        .cr_out1_o          (cr_out1            ),
        .cr_rts_o           (cr_rts             ),
        .cr_dtr_o           (cr_dtr             ),
        .cr_rxe_o           (cr_rxe             ),
        .cr_txe_o           (cr_txe             ),
        .cr_lbe_o           (cr_lbe             ),
        .cr_sirlp_o         (cr_sirlp           ),
        .cr_siren_o         (cr_siren           ),
        .cr_uarten_o        (cr_uarten          )
    );

    logic bclk_tick;

    uart_bclk_gen
    u_bclk_gen (
        .clk_i              (pclk_i             ),
        .rst_ni             (prst_ni            ),
        .uartibrd_i         (uartibrd           ),
        .uartfbrd_i         (uartfbrd           ),
        .bclk_tick_o        (bclk_tick          )
    );

    logic [11:0]    uart_rx_data;
    logic           uart_rx_data_rdy;

    logic [7:0]     uart_tx_data;
    logic           uart_tx_data_rdy;
    logic           uart_tx_data_ack;

    logic rx_empty;
    logic tx_empty;

    fifo_sync_sram #(.FIFO_DEPTH(32), .DATA_WIDTH(12))
    u_rx_fifo (
        .clk_i              (uart_clk           ),
        .rst_ni             (uart_rst_n         ),
        .we_i               (uart_rx_data_rdy   ),
        .wdata_i            (uart_rx_data       ),
        .full_o             (                   ),
        .re_i               (rx_re              ),
        .rdata_o            (rx_data            ),
        .empty_o            (rx_empty           )
    );

    fifo_sync_sram #(.FIFO_DEPTH(32), .DATA_WIDTH(8))
    u_tx_fifo (
        .clk_i              (uart_clk           ),
        .rst_ni             (uart_rst_n         ),
        .we_i               (tx_we              ),
        .wdata_i            (tx_data            ),
        .full_o             (                   ),
        .re_i               (uart_tx_data_ack   ),
        .rdata_o            (uart_tx_data       ),
        .empty_o            (tx_empty           )
    );

    assign uart_tx_data_rdy = ~tx_empty;

    logic uart_rx_en;
    logic uart_tx_en;

    uart_rx
    u_rx (
        .clk_i              (uart_clk           ),
        .rst_ni             (uart_rst_n         ),
        .uart_rx_en_i       (uart_rx_en         ),
        .bclk_tick_i        (bclk_tick          ),
        .lcr_sps_i          (lcr_srs            ),
        .lcr_wlen_i         (lcr_wlen           ),
        .lcr_fen_i          (lcr_fen            ),
        .lcr_stp2_i         (lcr_stp2           ),
        .lcr_eps_i          (lcr_eps            ),
        .lcr_pen_i          (lcr_pen            ),
        .lcr_brk_i          (lcr_brk            ),
        .uart_rx_data_o     (uart_rx_data       ),
        .uart_rx_data_rdy_o (uart_rx_data_rdy   ),
        .uart_rx_i          (uart_rx_i          )
    );

    uart_tx
    u_tx (
        .clk_i              (uart_clk           ),
        .rst_ni             (uart_rst_n         ),
        .uart_tx_en_i       (uart_tx_en         ),
        .bclk_tick_i        (bclk_tick          ),
        .lcr_sps_i          (lcr_srs            ),
        .lcr_wlen_i         (lcr_wlen           ),
        .lcr_fen_i          (lcr_fen            ),
        .lcr_stp2_i         (lcr_stp2           ),
        .lcr_eps_i          (lcr_eps            ),
        .lcr_pen_i          (lcr_pen            ),
        .lcr_brk_i          (lcr_brk            ),
        .uart_tx_data_i     (uart_tx_data       ),
        .uart_tx_data_rdy_i (uart_tx_data_rdy   ),
        .uart_tx_data_ack_o (uart_tx_data_ack   ),
        .uart_tx_o          (uart_tx_o          )
    );

    uart_fctrl
    u_fctrl (
        .cr_ctsen_i         (cr_ctsen           ),
        .cr_rtsen_i         (cr_rtsen           ),
        .cr_out2_i          (cr_out2            ),
        .cr_out1_i          (cr_out1            ),
        .cr_rts_i           (cr_rts             ),
        .cr_dtr_i           (cr_dtr             ),
        .cr_rxe_i           (cr_rxe             ),
        .cr_txe_i           (cr_txe             ),
        .cr_lbe_i           (cr_lbe             ),
        .cr_sirlp_i         (cr_sirlp           ),
        .cr_siren_i         (cr_siren           ),
        .cr_uarten_i        (cr_uarten          ),

        .uart_rx_en_o       (uart_rx_en         ),
        .uart_tx_en_o       (uart_tx_en         ),

        .uart_ri_ni         (uart_ri_ni         ),
        .uart_cts_ni        (uart_cts_ni        ),
        .uart_dsr_ni        (uart_dsr_ni        ),
        .uart_dcd_ni        (uart_dcd_ni        ),
        .uart_dtr_no        (uart_dtr_no        ),
        .uart_rts_no        (uart_rts_no        ),
        .uart_out1_no       (uart_out1_no       ),
        .uart_out2_no       (uart_out2_no       )
    );

endmodule : uart_apb_top
