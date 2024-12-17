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
// Name: uart_reg.sv
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

module uart_reg (

    input  logic            clk_i,
    input  logic            rst_ni,

    input  logic            reg_access_i,
    input  logic [11:0]     reg_addr_i,
    input  logic            reg_we_i,
    input  logic [15:0]     reg_wdata_i,
    output logic [15:0]     reg_rdata_o,

    input  logic [11:0]     rx_data_i,
    output logic            rx_re_o,
    output logic [ 7:0]     tx_data_o,
    output logic            tx_we_o,

    output logic [15:0]     uartibrd_o,
    output logic [ 5:0]     uartfbrd_o,

    output logic            lcr_sps_o,
    output logic [ 1:0]     lcr_wlen_o,
    output logic            lcr_fen_o,
    output logic            lcr_stp2_o,
    output logic            lcr_eps_o,
    output logic            lcr_pen_o,
    output logic            lcr_brk_o,

    output logic            cr_ctsen_o,
    output logic            cr_rtsen_o,
    output logic            cr_out2_o,
    output logic            cr_out1_o,
    output logic            cr_rts_o,
    output logic            cr_dtr_o,
    output logic            cr_rxe_o,
    output logic            cr_txe_o,
    output logic            cr_lbe_o,
    output logic            cr_sirlp_o,
    output logic            cr_siren_o,
    output logic            cr_uarten_o

);

    /*
     * UART DATA REGISTER
     */

    logic [7:0] reg_uartdr_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) reg_uartdr_q <= 8'h0;
        else if(reg_we_i == 1'b0 && reg_addr_i == 12'h000) begin
            reg_uartdr_q <= rx_data_i[7:0];
        end
    end

    assign rx_re_o = reg_access_i == 1'b1 && reg_we_i == 1'b0 && reg_addr_i == 12'h000;
    assign tx_we_o = reg_access_i == 1'b1 && reg_we_i == 1'b1 && reg_addr_i == 12'h000;

    assign tx_data_o = reg_wdata_i[7:0];


    /*
     * INTEGER BAUD RATE REGISTER
     */

    logic [15:0] reg_uartibrd_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) reg_uartibrd_q <= 16'h0;
        else if(reg_we_i == 1'b1 && reg_addr_i == 12'h024) begin
            reg_uartibrd_q <= reg_wdata_i;
        end
    end

    assign uartibrd_o = reg_uartibrd_q;


    /*
     * LINE CONTROL REGISTER
     */

    //////////////////////////////////////////
    // bits     name    function
    //////////////////////////////////////////
    // 15:8     -       read-only zero
    // 7        SPS     stick parity select
    // 6:5      WLEN    word length
    // 4        FEN     FIFO enable
    // 3        STP2    two stop bits enable
    // 2        EPS     even parity select
    // 1        PEN     parity enable
    // 0        BRK     send break
    //////////////////////////////////////////

    logic [15:0] reg_uartlcr_h_q;
    logic [15:0] reg_uartlcr_h_d;

    always_comb begin
        reg_uartlcr_h_d = reg_uartlcr_h_q;

        if(reg_we_i == 1'b1 && reg_addr_i == 12'h02c) begin
            reg_uartlcr_h_d = reg_wdata_i;
        end

        reg_uartlcr_h_d[15:8] = 8'h0;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) reg_uartlcr_h_q <= 16'h0;
        else reg_uartlcr_h_q <= reg_uartlcr_h_d;
    end

    assign lcr_sps_o  = reg_uartlcr_h_q[7];
    assign lcr_wlen_o = reg_uartlcr_h_q[6:5];
    assign lcr_fen_o  = reg_uartlcr_h_q[4];
    assign lcr_stp2_o = reg_uartlcr_h_q[3];
    assign lcr_eps_o  = reg_uartlcr_h_q[2];
    assign lcr_pen_o  = reg_uartlcr_h_q[1];
    assign lcr_brk_o  = reg_uartlcr_h_q[0];


    /*
     * CONTROL REGISTER
     */

    logic [15:0] reg_uartcr_q;
    logic [15:0] reg_uartcr_d;

    always_comb begin
        reg_uartcr_d = reg_uartcr_q;

        if(reg_we_i == 1'b1 && reg_addr_i == 12'h030) begin
            reg_uartcr_d = reg_wdata_i;
        end
        reg_uartcr_d[6:3] = 4'h0;

        // TODO: implement SIR
        reg_uartcr_d[2:1] = 2'b00;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) reg_uartcr_q <= 16'h0300;
        else reg_uartcr_q <= reg_uartcr_d;
    end

    assign cr_ctsen_o  = reg_uartcr_q[15];
    assign cr_rtsen_o  = reg_uartcr_q[14];
    assign cr_out2_o   = reg_uartcr_q[13];
    assign cr_out1_o   = reg_uartcr_q[12];
    assign cr_rts_o    = reg_uartcr_q[11];
    assign cr_dtr_o    = reg_uartcr_q[10];
    assign cr_rxe_o    = reg_uartcr_q[9];
    assign cr_txe_o    = reg_uartcr_q[8];
    assign cr_lbe_o    = reg_uartcr_q[7];
    assign cr_sirlp_o  = reg_uartcr_q[2];
    assign cr_siren_o  = reg_uartcr_q[1];
    assign cr_uarten_o = reg_uartcr_q[0];


    /*
     * REGISTER DATA OUT LOGIC
     */

    always_comb begin
        reg_rdata_o = 15'h0;

        case(reg_addr_i)
            12'h000: reg_rdata_o = reg_uartdr_q;
            12'h02c: reg_rdata_o = reg_uartlcr_h_q;
            12'h030: reg_rdata_o = reg_uartcr_q;
        endcase

        if(reg_we_i == 1'b1) reg_rdata_o = 15'h0;
    end

endmodule : uart_reg