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
// Name: rv_layering_uvc_cfg.sv
// Auth: Nikola Lukić
// Date: 16.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_LAYERING_UVC_CFG_SV
`define RV_LAYERING_UVC_CFG_SV

class rv_layering_uvc_cfg extends uvm_object;

    typedef rv_layering_uvc_agent_cfg   agent_cfg_t;

    /* ENVIRONMENT CONFIG OBJECTS */
    agent_cfg_t     agent_cfg = agent_cfg_t::type_id::create("agent_cfg");

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(rv_layering_uvc_cfg)
        `uvm_field_object(agent_cfg, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : rv_layering_uvc_cfg

`endif // RV_LAYERING_UVC_CFG_SV
