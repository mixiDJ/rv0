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
// Name: uart_uvc_seq_base.sv
// Auth: Nikola Lukić
// Date: 10.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_SEQ_PAR_ERR_SV
`define UART_UVC_SEQ_PAR_ERR_SV

class uart_uvc_seq_par_err extends uart_uvc_seq_base;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_uvc_seq_par_err)
        `uvm_field_int(uart_data,  UVM_DEFAULT)
        `uvm_field_int(uart_frame, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(uart_uvc_sequencer)

    /* SEQUENCE BODY TASK */
    extern virtual task body();

    /* SEQUENCE CALLBACKS */
    extern virtual task pre_do(bit is_item);
    extern virtual function void mid_do(uvm_sequence_item this_item);

endclass : uart_uvc_seq_par_err

task uart_uvc_seq_par_err::body();
    `uvm_do_with(req, { uart_frame == local::uart_frame; })
endtask : body

task uart_uvc_seq_par_err::pre_do(bit is_item);
    super.pre_do(is_item);
endtask : pre_do

function void uart_uvc_seq_par_err::mid_do(uvm_sequence_item this_item);
    REQ item;
    super.mid_do(this_item);

    $cast(item, this_item);

    // flip parity bit
    item.set_par_bit(~req.get_par_bit());

endfunction : mid_do

`endif // UART_UVC_SEQ_PAR_ERR_SV
