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
// Name: clk_uvc_agent_cfg.sv
// Auth: Nikola Lukić
// Date: 02.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_AGENT_CFG_SV
`define CLK_UVC_AGENT_CFG_SV

class clk_uvc_agent_cfg extends uvm_object;

    /* AGENT CONFIG FIELDS */
    int unsigned        agent_id            = 0;
    uvm_agent_type_e    agent_type          = UVM_ACTIVE;

    bit                 clk_enable          = 1'b1;
    time                clk_period          = 10ns;
    real                clk_duty_cycle      = 0.5;
    real                clk_phase           = 0;

    bit                 rst_init            = 0;
    int                 rst_init_delay      = 3;
    time                rst_assert_delay    = 1ns;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(clk_uvc_agent_cfg)
        `uvm_field_int (                  agent_id,         UVM_DEFAULT)
        `uvm_field_enum(uvm_agent_type_e, agent_type,       UVM_DEFAULT)
        `uvm_field_int (                  clk_enable,       UVM_DEFAULT)
        `uvm_field_int (                  clk_period,       UVM_DEFAULT)
        `uvm_field_real(                  clk_duty_cycle,   UVM_DEFAULT)
        `uvm_field_real(                  clk_phase,        UVM_DEFAULT)
        `uvm_field_int (                  rst_init,         UVM_DEFAULT)
        `uvm_field_int (                  rst_init_delay,   UVM_DEFAULT)
        `uvm_field_int (                  rst_assert_delay, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : clk_uvc_agent_cfg

`endif // CLK_UVC_AGENT_CFG_SV
