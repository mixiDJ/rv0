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
// Name: sideband_uvc_monitor.sv
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

`ifndef SIDEBAND_UVC_MONITOR_SV
`define SIDEBAND_UVC_MONITOR_SV

class sideband_uvc_monitor extends uvm_monitor;

    typedef virtual sideband_uvc_if     vif_t;
    typedef sideband_uvc_agent_cfg      cfg_t;
    typedef sideband_uvc_item           item_t;

    /* MONITOR ANALYSIS PORTS */
    // TODO

    /* MONITOR CONFIG REF */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* REGISTRATION MACRO */
    `uvm_component_utils(sideband_uvc_monitor)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : sideband_uvc_monitor

function void sideband_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task sideband_uvc_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

    end

endtask : run_phase

`endif // SIDEBAND_UVC_MONITOR_SV
