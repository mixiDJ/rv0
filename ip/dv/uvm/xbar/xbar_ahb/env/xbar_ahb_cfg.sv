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
// Name: xbar_ahb_cfg.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_CFG_SV
`define XBAR_AHB_CFG_SV

class xbar_ahb_cfg #(`XBAR_AHB_PARAMS) extends uvm_object;

    /* ENVIRONMENT CONFIG OBJECTS */
    clk_uvc_cfg     clk_env_cfg;
    ahb_uvc_cfg     ahb_master_env_cfg [0:XBAR_REQUESTER_CNT-1];
    ahb_uvc_cfg     ahb_slave_env_cfg  [0:XBAR_COMPLETER_CNT-1];

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(xbar_ahb_cfg#(`XBAR_AHB_PARAM_LST))
        `uvm_field_object       (clk_env_cfg,        UVM_DEFAULT)
        `uvm_field_sarray_object(ahb_master_env_cfg, UVM_DEFAULT)
        `uvm_field_sarray_object(ahb_slave_env_cfg,  UVM_DEFAULT)
    `uvm_object_utils_end

    /* CONSTRUCTOR */
    extern function new(string name="");

endclass : xbar_ahb_cfg

function xbar_ahb_cfg::new(string name="");
    super.new(name);

    clk_env_cfg = clk_uvc_cfg::type_id::create("clk_env_cfg");

    for(uint i = 0; i < XBAR_REQUESTER_CNT; ++i) begin
        string ahb_cfg_id = $sformatf("ahb_master_env_cfg_%0d", i);
        ahb_master_env_cfg[i] = ahb_uvc_cfg::type_id::create(ahb_cfg_id);
        ahb_master_env_cfg[i].has_master_agent = 1;
        ahb_master_env_cfg[i].has_slave_agent  = 0;
    end

    for(uint i = 0; i < XBAR_COMPLETER_CNT; ++i) begin
        string ahb_cfg_id = $sformatf("ahb_slave_env_cfg_%0d", i);
        ahb_slave_env_cfg[i] = ahb_uvc_cfg::type_id::create(ahb_cfg_id);
        ahb_slave_env_cfg[i].has_master_agent = 0;
        ahb_slave_env_cfg[i].has_slave_agent  = 1;
    end

endfunction : new

`endif // XBAR_AHB_CFG_SV
