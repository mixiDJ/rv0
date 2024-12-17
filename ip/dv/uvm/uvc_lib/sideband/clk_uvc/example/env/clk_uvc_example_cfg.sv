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
// Name: clk_uvc_example_cfg.sv
// Auth: Nikola Lukić
// Date: 04.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_EXAMPLE_CFG_SV
`define CLK_UVC_EXAMPLE_CFG_SV

class clk_uvc_example_cfg extends uvm_object;

    /* CONFIG FIELDS */
    clk_uvc_cfg clk_env_cfg;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(clk_uvc_example_cfg)
        `uvm_field_object(clk_env_cfg, UVM_DEFAULT)
    `uvm_object_utils_end

    /* CONSTRUCTOR */
    extern function new(string name="");

endclass : clk_uvc_example_cfg

function clk_uvc_example_cfg::new(string name="");
    super.new(name);
    clk_env_cfg = clk_uvc_cfg::type_id::create("clk_env_cfg");
endfunction : new

`endif // CLK_UVC_EXAMPLE_CFG_SV
