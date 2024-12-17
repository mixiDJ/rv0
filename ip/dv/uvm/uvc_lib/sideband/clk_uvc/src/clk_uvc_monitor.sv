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
// Name: clk_uvc_monitor.sv
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

`ifndef CLK_UVC_MONITOR_SV
`define CLK_UVC_MONITOR_SV

class clk_uvc_monitor extends uvm_monitor;

    typedef virtual clk_uvc_if  vif_t;
    typedef clk_uvc_agent_cfg   cfg_t;
    typedef clk_uvc_item        item_t;

    /* MONITOR ANALYSIS PORTS */
    uvm_analysis_port#(item_t)  m_aport;

    /* MONITOR CONFIG REF */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* MONITOR SEQUENCE ITEM */
    item_t m_item;

    /* MONITOR EVENTS */
    uvm_event   m_rst_assert_event;
    uvm_event   m_rst_deassert_event;

    /* REGISTRATION MACRO */
    `uvm_component_utils(clk_uvc_monitor)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */

endclass : clk_uvc_monitor

function void clk_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get monitor config from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // create analysis ports
    m_aport = new("m_aport", this);

    // get UVM global event handles
    m_rst_assert_event   = uvm_event_pool::get_global(
        $sformatf("m_rst_assert_event_%0d", m_cfg.agent_id)
    );

    m_rst_deassert_event = uvm_event_pool::get_global(
        $sformatf("m_rst_deassert_event_%0d", m_cfg.agent_id)
    );

endfunction : build_phase

task clk_uvc_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork

        begin
            forever begin
                @(posedge m_vif.clk);
                m_item = item_t::type_id::create("m_item", this);
                m_item.typ = CLK_POSEDGE;
                m_aport.write(m_item);
            end
        end

        begin
            forever begin
                @(negedge m_vif.clk);
                m_item = item_t::type_id::create("m_item", this);
                m_item.typ = CLK_NEGEDGE;
                m_aport.write(m_item);
            end
        end

        begin
            forever begin
                @(negedge m_vif.rst_n);
                m_item = item_t::type_id::create("m_item", this);
                m_item.typ = RST_ASSERT;
                m_aport.write(m_item);
                m_rst_assert_event.trigger();
            end
        end

        begin
            forever begin
                @(posedge m_vif.rst_n);
                m_item = item_t::type_id::create("m_item", this);
                m_item.typ = RST_DEASSERT;
                m_aport.write(m_item);
                m_rst_deassert_event.trigger();
            end
        end

    join_none

endtask : run_phase

`endif // CLK_UVC_MONITOR_SV
