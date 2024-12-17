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
// Name: uart_apb_vseq_base.sv
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

`ifndef UART_APB_VSEQ_BASE_SV
`define UART_APB_VSEQ_BASE_SV

class uart_apb_vseq_base extends uvm_sequence;

    typedef clk_uvc_seq_rst             clk_seq_rst_t;

    typedef apb_uvc_seq_base            apb_seq_base_t;

    typedef uart_uvc_seq_base           uart_seq_base_t;
    typedef uart_uvc_seq_frm_err        uart_seq_frm_err_t;
    typedef uart_uvc_seq_par_err        uart_seq_par_err_t;
    typedef uart_uvc_seq_brk            uart_seq_brk_t;

    /* VIRTUAL SEQUENCES */

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_apb_vseq_base)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(uart_apb_vsequencer)

endclass : uart_apb_vseq_base

`endif // UART_APB_VSEQ_BASE_SV
