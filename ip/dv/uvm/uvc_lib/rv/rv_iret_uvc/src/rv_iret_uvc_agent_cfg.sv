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
// Name: rv_iret_uvc_agent_cfg.sv
// Auth: Nikola Lukić
// Date: 21.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_IRET_UVC_AGENT_CFG_SV
`define RV_IRET_UVC_AGENT_CFG_SV

class rv_iret_uvc_agent_cfg extends uvm_object;

    /* AGENT CONFIG FIELDS */
    bit has_cov = 0;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(rv_iret_uvc_agent_cfg)
        `uvm_field_int(has_cov, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : rv_iret_uvc_agent_cfg

`endif // RV_ITER_UVC_AGENT_CFG_SV
