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
// Name: clk_uvc_cfg.sv
// Auth: Nikola Lukić
// Date: 03.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_CFG_SV
`define CLK_UVC_CFG_SV

class clk_uvc_cfg extends uvm_object;

    int unsigned       agent_cnt = 1;
    clk_uvc_agent_cfg  agent_cfg [];

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(clk_uvc_cfg)
        `uvm_field_int         (agent_cnt, UVM_DEFAULT)
        `uvm_field_array_object(agent_cfg, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : clk_uvc_cfg

`endif // CLK_UVC_CFG_SV
