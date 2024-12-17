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
// Name: uart_uvc_agent_cfg.sv
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

`ifndef UART_UVC_AGENT_CFG_SV
`define UART_UVC_AGENT_CFG_SV

class uart_uvc_agent_cfg extends uvm_object;

    /* AGENT CONFIG FIELDS */
    uvm_agent_type_e    agent_type = UVM_ACTIVE;
    int unsigned        baud_rate  = 9600;
    int unsigned        data_bits  = 8;
    int unsigned        par_bit    = 1;
    par_typ_e           par_typ    = PAR_TYP_ODD;
    bit                 par_stck   = 0;
    int unsigned        stop_bits  = 1;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_uvc_agent_cfg)
        `uvm_field_enum(uvm_agent_type_e, agent_type, UVM_DEFAULT)
        `uvm_field_int (                  baud_rate,  UVM_DEFAULT)
        `uvm_field_int (                  data_bits,  UVM_DEFAULT)
        `uvm_field_int (                  par_bit,    UVM_DEFAULT)
        `uvm_field_enum(par_typ_e,        par_typ,    UVM_DEFAULT)
        `uvm_field_int (                  par_stck,   UVM_DEFAULT)
        `uvm_field_int (                  stop_bits,  UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

    /* METHODS */
    extern function time get_bit_time();
    extern function uint get_frame_size();

endclass : uart_uvc_agent_cfg

function time uart_uvc_agent_cfg::get_bit_time();
    return (1s/(baud_rate));
endfunction : get_bit_time

function uint uart_uvc_agent_cfg::get_frame_size();
    return 1 + data_bits + par_bit + stop_bits;
endfunction : get_frame_size

`endif // UART_UVC_AGENT_CFG_SV
