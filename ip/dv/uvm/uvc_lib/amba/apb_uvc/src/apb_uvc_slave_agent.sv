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
// Name: apb_uvc_slave_agent.sv
// Auth: Nikola Lukić
// Date: 16.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_SLAVE_AGENT_SV
`define APB_UVC_SLAVE_AGENT_SV

class apb_uvc_slave_agent #(`APB_UVC_PARAM_LST) extends uvm_agent;

    typedef virtual apb_uvc_if#(`APB_UVC_PARAMS)        vif_t;
    typedef apb_uvc_slave_driver#(`APB_UVC_PARAMS)      driver_t;
    typedef apb_uvc_monitor#(`APB_UVC_PARAMS)           monitor_t;
    typedef apb_uvc_sequencer#(`APB_UVC_PARAMS)         sequencer_t;
    typedef apb_uvc_item#(`APB_UVC_PARAMS)              item_t;
    typedef apb_uvc_agent_cfg                           cfg_t;

    /* AGENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_req_aport;
    uvm_analysis_port#(item_t) m_rsp_aport;

    /* AGENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* AGENT VIRTUAL INTERFACE */
    vif_t m_vif;

    /* AGENT COMPONENTS */
    driver_t    m_driver;
    monitor_t   m_monitor;
    sequencer_t m_sequencer;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_slave_agent#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : apb_uvc_slave_agent

function void apb_uvc_slave_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // print agent config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    m_req_aport = new("m_req_aport", this);
    m_rsp_aport = new("m_rsp_aport", this);

    if(m_cfg.agent_type == UVM_ACTIVE) begin

        // create driver component
        m_driver = driver_t::type_id::create("m_driver", this);

        // set driver config ref
        `uvm_config_db_set(cfg_t, this, "m_driver", "m_cfg", m_cfg)

        // set driver virtual interface
        `uvm_config_db_set(vif_t, this, "m_driver", "m_vif", m_vif)

        // create sequencer component
        m_sequencer = sequencer_t::type_id::create("m_sequencer", this);

        // set sequencer config ref
        `uvm_config_db_set(cfg_t, this, "m_sequencer", "m_cfg", m_cfg)

    end

    // create monitor component
    m_monitor = monitor_t::type_id::create("m_monitor", this);

    // set monitor config object
    `uvm_config_db_set(cfg_t, this, "m_monitor", "m_cfg", m_cfg)

    // set monitor virtual interface
    `uvm_config_db_set(vif_t, this, "m_monitor", "m_vif", m_vif)

endfunction : build_phase

function void apb_uvc_slave_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect driver sequence item port
    if(m_cfg.agent_type == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end

    // connect monitor analysis ports
    m_monitor.m_req_aport.connect(m_req_aport);
    m_monitor.m_rsp_aport.connect(m_rsp_aport);

endfunction : connect_phase

`endif // APB_UVC_SLAVE_AGENT_SV
