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
// Name: sideband_uvc_agent.sv
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

`ifndef SIDEBAND_UVC_AGENT_SV
`define SIDEBAND_UVC_AGENT_SV

class sideband_uvc_agent extends uvm_agent;

    typedef virtual sideband_uvc_if     vif_t;
    typedef sideband_uvc_driver         driver_t;
    typedef sideband_uvc_monitor        monitor_t;
    typedef sideband_uvc_sequencer      sequencer_t;
    typedef sideband_uvc_item           item_t;
    typedef sideband_uvc_agent_cfg      cfg_t;

    /* AGENT ANALYSIS PORTS */
    // TODO

    /* AGENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* AGENT VIRTUAL INTERFACE */
    vif_t m_vif;

    /* AGENT COMPONENTS */
    driver_t    m_driver;
    monitor_t   m_monitor;
    sequencer_t m_sequencer;

    /* REGISTRATION MACRO */
    `uvm_component_utils(sideband_uvc_agent)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : sideband_uvc_agent

function void sideband_uvc_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get agent config object
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get agent virtual interface
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // print agent config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    // TODO

    if(m_cfg.agent_type == UVM_ACTIVE) begin

        // create driver component
        m_driver = driver_t::type_id::create("m_driver", this);

        // set driver config ref
        m_driver.m_cfg = m_cfg;

        // set driver virtual interface
        `uvm_config_db_set(vif_t, this, "m_driver", "m_vif", m_vif)

        // create sequencer component
        m_sequencer = sequencer_t::type_id::create("m_sequencer", this);

        // set sequencer config ref
        m_sequencer.m_cfg = m_cfg;

    end

    // create monitor component
    m_monitor = monitor_t::type_id::create("m_monitor", this);

    // set monitor config ref
    m_monitor.m_cfg = m_cfg;

    // set monitor virtual interface
    `uvm_config_db_set(vif_t, this, "m_monitor", "m_vif", m_vif)

endfunction : build_phase

function void sideband_uvc_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

`endif // SIDEBAND_UVC_AGENT_SV
