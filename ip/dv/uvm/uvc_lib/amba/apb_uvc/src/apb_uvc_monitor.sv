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
// Name: apb_uvc_monitor.sv
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

`ifndef APB_UVC_MONITOR_SV
`define APB_UVC_MONITOR_SV

class apb_uvc_monitor #(`APB_UVC_PARAM_LST) extends uvm_monitor;

    typedef virtual apb_uvc_if#(`APB_UVC_PARAMS)    vif_t;
    typedef apb_uvc_item#(`APB_UVC_PARAMS)          item_t;
    typedef apb_uvc_agent_cfg                       cfg_t;

    /* MONITOR ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_req_aport;
    uvm_analysis_port#(item_t) m_rsp_aport;

    /* MONITOR CONFIG REF */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* MONITOR SEQUENCE ITEMS */
    item_t m_req;
    item_t m_rsp;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_monitor#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern virtual task seq_item_handler();
    extern virtual task reset_handler();

endclass : apb_uvc_monitor

function void apb_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // create analysis ports
    m_req_aport = new("m_req_aport", this);
    m_rsp_aport = new("m_rsp_aport", this);

endfunction : build_phase

task apb_uvc_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin : monitor_run_phase_blk

        wait(m_vif.prst_n == 1'b1);

        fork
            begin
                seq_item_handler();
            end
            begin
                reset_handler();
            end
        join_any
        disable fork;

    end // monitor_run_phase_blk

endtask : run_phase

task apb_uvc_monitor::seq_item_handler();

    @(posedge m_vif.pclk iff (m_vif.psel == 1'b1));
    m_req = item_t::type_id::create("m_req", this);

    m_req.paddr  = m_vif.paddr;
    m_req.pprot  = m_vif.pprot;
    m_req.pnse   = m_vif.pnse;
    m_req.pwrite = m_vif.pwrite;
    m_req.pwdata = m_vif.pwdata;
    m_req.pstrb  = m_vif.pstrb;
    m_req.pauser = m_vif.pauser;
    m_req.pwuser = m_vif.pwuser;

    m_req_aport.write(m_req);

    @(posedge m_vif.pclk iff (m_vif.pready == 1'b1));

    $cast(m_rsp, m_req.clone());

    m_rsp.prdata  = m_vif.prdata;
    m_rsp.pslverr = m_vif.pslverr;
    m_rsp.pruser  = m_vif.pruser;
    m_rsp.pbuser  = m_vif.pbuser;

    m_rsp_aport.write(m_rsp);

endtask : seq_item_handler

task apb_uvc_monitor::reset_handler();
    wait(m_vif.prst_n == 1'b0);
    `uvm_info(`gtn, "RESET SIGNAL ASSERTED", UVM_HIGH)
endtask : reset_handler

`endif // APB_UVC_MONITOR_SV
