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
// Name: uart_fctrl.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_fctrl (

    /* CONTROL REGISTER INTERFACE */
    input  logic    cr_ctsen_i,
    input  logic    cr_rtsen_i,
    input  logic    cr_out2_i,
    input  logic    cr_out1_i,
    input  logic    cr_rts_i,
    input  logic    cr_dtr_i,
    input  logic    cr_rxe_i,
    input  logic    cr_txe_i,
    input  logic    cr_lbe_i,
    input  logic    cr_sirlp_i,
    input  logic    cr_siren_i,
    input  logic    cr_uarten_i,

    /* RX/TX ENABLE SIGNALS */
    output logic    uart_rx_en_o,
    output logic    uart_tx_en_o,

    /* FLOW CONTROL SIGNALS */
    input  logic    uart_ri_ni,
    input  logic    uart_cts_ni,
    input  logic    uart_dsr_ni,
    input  logic    uart_dcd_ni,
    output logic    uart_dtr_no,
    output logic    uart_rts_no,
    output logic    uart_out1_no,
    output logic    uart_out2_no

);

    always_comb begin
        uart_rx_en_o = cr_uarten_i == 1'b1 && cr_rxe_i == 1'b1;
        if(cr_rtsen_i == 1'b1) begin
            uart_rx_en_o = uart_rx_en_o == 1'b1 && uart_rts_no == 1'b0;
        end
    end

    always_comb begin
        uart_tx_en_o = cr_uarten_i == 1'b1 && cr_txe_i == 1'b1;
        if(cr_ctsen_i == 1'b1) begin
            uart_tx_en_o = uart_tx_en_o == 1'b1 && uart_cts_ni == 1'b0;
        end
    end

    always_comb begin
        uart_rts_no = ~cr_rts_i;
        if(cr_rtsen_i == 1'b1) begin
            // TODO: add watermark check
        end
    end

    assign uart_dtr_no  = ~cr_dtr_i;
    assign uart_out1_no = ~cr_out1_i;
    assign uart_out2_no = ~cr_out2_i;

endmodule : uart_fctrl
