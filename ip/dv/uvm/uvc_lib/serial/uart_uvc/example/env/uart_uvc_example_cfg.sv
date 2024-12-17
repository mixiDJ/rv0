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
// Name: uart_uvc_example_cfg.sv
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

`ifndef UART_UVC_EXAMPLE_CFG_SV
`define UART_UVC_EXAMPLE_CFG_SV

class uart_uvc_example_cfg extends uvm_object;

    /* CONFIG FIELDS */
    uart_uvc_cfg uart_env_cfg[2];

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_uvc_example_cfg)
        `uvm_field_sarray_object(uart_env_cfg, UVM_DEFAULT)
    `uvm_object_utils_end

    /* CONSTRUCTOR */
    extern function new(string name="");

endclass : uart_uvc_example_cfg

function uart_uvc_example_cfg::new(string name="");
    super.new(name);
    uart_env_cfg[0] = uart_uvc_cfg::type_id::create("uart_env_cfg_0");
    uart_env_cfg[1] = uart_uvc_cfg::type_id::create("uart_env_cfg_1");
endfunction : new

`endif // UART_UVC_EXAMPLE_CFG_SV
