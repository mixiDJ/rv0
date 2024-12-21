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
// Name: ahb_uvc_monitor.sv
// Auth: Nikola Lukić
// Date: 29.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_MONITOR_SV
`define AHB_UVC_MONITOR_SV

class ahb_uvc_monitor #(`AHB_UVC_PARAM_LST) extends uvm_monitor;

    typedef virtual ahb_uvc_if#(`AHB_UVC_PARAMS)    vif_t;
    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)          item_t;
    typedef ahb_uvc_agent_cfg                       cfg_t;

    /* MONITOR ANALYSIS PORTS */
    uvm_analysis_port#(item_t)  m_req_aport;
    uvm_analysis_port#(item_t)  m_rsp_aport;

    /* MONITOR CONFIG OBJECT */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* MONITOR QUEUE MUTEX */
    semaphore m_bus_lock = new(1);

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(ahb_uvc_monitor#(`AHB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task bus_collector();
    extern local task reset_handler();

    extern function bit check_bus_req_valid();

endclass : ahb_uvc_monitor

function void ahb_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // create analysis ports
    m_req_aport = new("m_req_aport", this);
    m_rsp_aport = new("m_rsp_aport", this);

endfunction : build_phase

task ahb_uvc_monitor::run_phase(uvm_phase phase);

    forever begin

        wait(m_vif.hrst_n == 1'b1);

        fork
            begin
                bus_collector();
            end
            begin
                bus_collector();
            end
            begin
                reset_handler();
            end
        join_any
        disable fork;

    end

endtask : run_phase

task ahb_uvc_monitor::bus_collector();

    forever begin
        item_t ahb_item;
        ahb_item = item_t::type_id::create("ahb_item", this);

        m_bus_lock.get(1);

        // wait for valid bus request
        while(check_bus_req_valid() == 1'b0) @(posedge m_vif.hclk);

        // collect bus request data
        ahb_item.haddr     = m_vif.haddr;
        ahb_item.hburst    = m_vif.hburst;
        ahb_item.hmastlock = m_vif.hmastlock;
        ahb_item.hprot     = m_vif.hprot;
        ahb_item.hnonsec   = m_vif.hnonsec;
        ahb_item.hexcl     = m_vif.hexcl;
        ahb_item.hmaster   = m_vif.hmaster;
        ahb_item.htrans    = m_vif.htrans;
        ahb_item.hwstrb    = m_vif.hwstrb;
        ahb_item.hwrite    = m_vif.hwrite;
        ahb_item.hauser    = m_vif.hauser;
        ahb_item.hwuser    = m_vif.hwuser;

        // collect write data
        @(posedge m_vif.hclk);
        ahb_item.hwdata = m_vif.hwdata;

        // wait for request acknowledge
        m_bus_lock.put();

        // wait for response
        while(m_vif.hreadyout == 1'b0) @(posedge m_vif.hclk);

        // collect response data
        ahb_item.hrdata  = m_vif.hrdata;
        ahb_item.hresp   = m_vif.hresp;
        ahb_item.hexokay = m_vif.hexokay;
        ahb_item.hruser  = m_vif.hruser;
        ahb_item.hbuser  = m_vif.hbuser;

        m_rsp_aport.write(ahb_item);

        `uvm_info(`gtn, {"\nAHB RSP:\n", ahb_item.sprint()}, UVM_HIGH)

    end

endtask : bus_collector

task ahb_uvc_monitor::reset_handler();
    // wait for reset signal assertion
    @(negedge m_vif.hrst_n);
    `uvm_info(`gtn, "\nRESET SIGNAL ASSERTED", UVM_HIGH)
endtask : reset_handler

function bit ahb_uvc_monitor::check_bus_req_valid();
    if(m_vif.hsel == 1'b0) return 0;
    if(m_vif.htrans == HTRANS_IDLE) return 0;
    if(m_vif.htrans == HTRANS_BUSY) return 0;
    if(m_vif.hreadyout == 1'b0) return 0;
    return 1;
endfunction : check_bus_req_valid

`endif // AHB_UVC_MONITOR_SV
