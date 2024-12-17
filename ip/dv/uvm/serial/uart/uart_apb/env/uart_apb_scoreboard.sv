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
// Name: uart_apb_scoreboard.sv
// Auth: Nikola Lukić
// Date: 22.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_APB_SCOREBOARD_SV
`define UART_APB_SCOREBOARD_SV

class uart_apb_scoreboard extends uvm_scoreboard;

    typedef clk_uvc_item            clk_seq_item_t;
    typedef apb_uvc_item            apb_seq_item_t;
    typedef uart_uvc_item           uart_seq_item_t;
    typedef uart_apb_scoreboard     scoreboard_t;

    /* SCOREBOARD ANALYSIS PORTS */
    uvm_analysis_imp_clk#(
        clk_seq_item_t,
        scoreboard_t
    ) m_clk_imp;

    uvm_analysis_imp_apb#(
        apb_seq_item_t,
        scoreboard_t
    ) m_apb_master_rsp_imp;

    uvm_analysis_imp_uart_rx#(
        uart_seq_item_t,
        scoreboard_t
    ) m_uart_rx_imp;

    uvm_analysis_imp_uart_tx#(
        uart_seq_item_t,
        scoreboard_t
    ) m_uart_tx_imp;

    /* REGISTRATION MACRO */
    `uvm_component_utils(uart_apb_scoreboard)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);

    /* ANALYSIS PORT METHODS */
    extern virtual function void write_clk(clk_seq_item_t t);
    extern virtual function void write_apb(apb_seq_item_t t);
    extern virtual function void write_uart_rx(uart_seq_item_t t);
    extern virtual function void write_uart_tx(uart_seq_item_t t);

endclass : uart_apb_scoreboard

function void uart_apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void uart_apb_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);
endfunction : check_phase

function void uart_apb_scoreboard::write_clk(clk_seq_item_t t);

endfunction : write_clk

function void uart_apb_scoreboard::write_apb(apb_seq_item_t t);

endfunction : write_apb

function void uart_apb_scoreboard::write_uart_rx(uart_seq_item_t t);

endfunction : write_uart_rx

function void uart_apb_scoreboard::write_uart_tx(uart_seq_item_t t);

endfunction : write_uart_tx

`endif // UART_APB_SCOREBOARD_SV
