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
// Name: clk_uvc_agent.sv
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

`ifndef CLK_UVC_AGENT_SV
`define CLK_UVC_AGENT_SV

class clk_uvc_agent extends uvm_agent;

    typedef virtual clk_uvc_if      vif_t;
    typedef clk_uvc_driver          driver_t;
    typedef clk_uvc_monitor         monitor_t;
    typedef clk_uvc_sequencer       sequencer_t;
    typedef clk_uvc_item            item_t;
    typedef clk_uvc_agent_cfg       cfg_t;

    /* AGENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_aport;

    /* AGENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* AGENT VIRTUAL INTERFACE */
    vif_t m_vif;

    /* AGENT COMPONENTS */
    driver_t    m_driver;
    monitor_t   m_monitor;
    sequencer_t m_sequencer;

    /* REGISTRATION MACRO */
    `uvm_component_utils(clk_uvc_agent)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : clk_uvc_agent

function void clk_uvc_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get agent config
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get agent virtual interface
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // print agent config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    m_aport = new("m_aport", this);

    if(m_cfg.agent_type == UVM_ACTIVE) begin

        // create driver component
        m_driver = driver_t::type_id::create("m_driver", this);

        // set driver config
        `uvm_config_db_set(cfg_t, this, "m_driver", "m_cfg", m_cfg)

        // set driver virtual interface
        `uvm_config_db_set(vif_t, this, "m_driver", "m_vif", m_vif)

        // create sequencer component
        m_sequencer = sequencer_t::type_id::create("m_sequencer", this);

        // set sequencer config
        `uvm_config_db_set(cfg_t, this, "m_sequencer", "m_cfg", m_cfg)

    end

    // create monitor component
    m_monitor = monitor_t::type_id::create("m_monitor", this);

    // set monitor config ref
    `uvm_config_db_set(cfg_t, this, "m_monitor", "m_cfg", m_cfg)

    // set monitor virtual interface
    `uvm_config_db_set(vif_t, this, "m_monitor", "m_vif", m_vif)

endfunction : build_phase

function void clk_uvc_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect driver sequence item port
    if(m_cfg.agent_type == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end

    // connect monitor analysis ports
    m_monitor.m_aport.connect(m_aport);

endfunction : connect_phase

`endif // CLK_UVC_AGENT_SV
