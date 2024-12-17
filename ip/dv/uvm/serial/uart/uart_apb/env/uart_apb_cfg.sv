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
// Name: uart_apb_cfg.sv
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

`ifndef UART_APB_CFG_SV
`define UART_APB_CFG_SV

class uart_apb_cfg extends uvm_object;

    /* ENVIRONMENT CONFIG OBJECTS */
    clk_uvc_cfg     clk_env_cfg;
    apb_uvc_cfg     apb_env_cfg;
    uart_uvc_cfg    uart_env_cfg;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_apb_cfg)
        `uvm_field_object(clk_env_cfg,  UVM_DEFAULT)
        `uvm_field_object(apb_env_cfg,  UVM_DEFAULT)
        `uvm_field_object(uart_env_cfg, UVM_DEFAULT)
    `uvm_object_utils_end

    /* CONSTRUCTOR */
    extern function new(string name="");

endclass : uart_apb_cfg

function uart_apb_cfg::new(string name="");
    super.new(name);

    clk_env_cfg  =  clk_uvc_cfg::type_id::create("clk_env_cfg");
    apb_env_cfg  =  apb_uvc_cfg::type_id::create("apb_env_cfg");
    uart_env_cfg = uart_uvc_cfg::type_id::create("uart_env_cfg");

endfunction : new

`endif // UART_APB_CFG_SV
