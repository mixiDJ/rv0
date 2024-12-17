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
// Name: clk_uvc_example_env.sv
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

`ifndef CLK_UVC_EXAMPLE_ENV_SV
`define CLK_UVC_EXAMPLE_ENV_SV

class clk_uvc_example_env extends uvm_env;

    /* ENVIRONMENT CONFIG OBJECT */
    clk_uvc_example_cfg m_cfg;

    /* ENVIRONMENT COMPONENTS */
    clk_uvc_env m_clk_env;

    /* REGISTRATION MACRO */
    `uvm_component_utils(clk_uvc_example_env)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : clk_uvc_example_env

function void clk_uvc_example_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get environment config object
    `uvm_config_db_get(clk_uvc_example_cfg, this, "", "m_cfg", m_cfg)

    // print environment config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create clock environment component
    m_clk_env = clk_uvc_env::type_id::create("m_clk_env", this);

    // set clock environment config
    `uvm_config_db_set(clk_uvc_cfg, this, "m_clk_env", "m_cfg", m_cfg.clk_env_cfg)

endfunction : build_phase

function void clk_uvc_example_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

`endif // CLK_UVC_EXAMPLE_ENV_SV
