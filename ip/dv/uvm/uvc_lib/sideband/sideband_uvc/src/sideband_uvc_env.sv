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
// Name: sideband_uvc_env.sv
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

`ifndef SIDEBAND_UVC_ENV_SV
`define SIDEBAND_UVC_ENV_SV

class sideband_uvc_env extends uvm_env;

    typedef sideband_uvc_agent      agent_t;
    typedef sideband_uvc_item       item_t;
    typedef sideband_uvc_cfg        cfg_t;
    typedef sideband_uvc_agent_cfg  agent_cfg_t;

    /* ENVIRONMENT ANALYSIS PORTS */
    // TODO

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    // TODO

    /* REGISTRATION MACRO */
    `uvm_component_utils(sideband_uvc_env)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : sideband_uvc_env

function void sideband_uvc_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void sideband_uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

`endif // SIDEBAND_UVC_ENV_SV
