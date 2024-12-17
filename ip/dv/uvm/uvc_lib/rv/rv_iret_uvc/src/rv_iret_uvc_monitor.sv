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
// Name: rv_iret_uvc_monitor.sv
// Auth: Nikola Lukić
// Date: 20.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_IRET_UVC_MONITOR_SV
`define RV_IRET_UVC_MONITOR_SV

class rv_iret_uvc_monitor #(`RV_IRET_UVC_PARAM_LST) extends uvm_monitor;

    typedef rv_uvc_item#(`RV_UVC_PARAMS)                        item_t;
    typedef virtual rv_iret_uvc_if#(`RV_IRET_UVC_PARAMS)        vif_t;
    typedef rv_iret_uvc_agent_cfg                               cfg_t;

    /* MONITOR ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_aport;

    /* MONITOR CONFIG OBJECT */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv_iret_uvc_monitor#(`RV_IRET_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task insn_collector();
    extern local task reset_handler();

endclass : rv_iret_uvc_monitor

function void rv_iret_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get monitor config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get monitor virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // create analysis ports
    m_aport = new("m_aport", this);

endfunction : build_phase

task rv_iret_uvc_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

        wait(m_vif.rst_n);

        fork
            begin
                insn_collector();
            end
            begin
                reset_handler();
            end
        join_any
        disable fork;

    end

endtask : run_phase

task rv_iret_uvc_monitor::insn_collector();
    item_t item;

    @(posedge m_vif.clk iff (m_vif.iret == 1'b1));
    item = item_t::type_id::create("iret_item", this);

    item.addr = m_vif.addr;
    item.insn = m_vif.insn;
    item.res  = m_vif.ires;
    item.set_fields();

    `uvm_info(`gtn, {"\n", item.sprint()}, UVM_HIGH)
    m_aport.write(item);

endtask : insn_collector

task rv_iret_uvc_monitor::reset_handler();
    wait(m_vif.rst_n == 1'b0);
    `uvm_info(`gtn, "RESET SIGNAL ASSERTED", UVM_HIGH)
endtask : reset_handler

`endif // RV_IRET_UVC_MONITOR_SV
