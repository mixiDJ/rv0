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
// Name: ahb_uvc_cfg.sv
// Auth: Nikola Lukić
// Date: 29.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_CFG_SV
`define AHB_UVC_CFG_SV

class ahb_uvc_cfg extends uvm_object;

    typedef ahb_uvc_agent_cfg   agent_cfg_t;

    /* ENVIRONMENT CONFIG FIELDS */
    bit has_master_agent = 1'b1;
    bit has_slave_agent  = 1'b0;

    /* ENVIRONMENT CONFIG OBJECTS */
    agent_cfg_t master_agent_cfg = agent_cfg_t::type_id::create("master_agent_cfg");
    agent_cfg_t slave_agent_cfg  = agent_cfg_t::type_id::create("slave_agent_cfg");

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(ahb_uvc_cfg)
        `uvm_field_int   (has_master_agent, UVM_DEFAULT)
        `uvm_field_int   (has_slave_agent,  UVM_DEFAULT)
        `uvm_field_object(master_agent_cfg, UVM_DEFAULT)
        `uvm_field_object(slave_agent_cfg,  UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : ahb_uvc_cfg

`endif // AHB_UVC_CFG_SV
