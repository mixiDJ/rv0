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
// Name: bridge_ahb_apb_cov_apb.sv
// Auth: Nikola Lukić
// Date: 01.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_COV_APB_SV
`define BRIDGE_AHB_APB_COV_APB_SV

class bridge_ahb_apb_cov_apb #(`APB_UVC_PARAMS) extends uvm_subscriber#(apb_uvc_item#(`APB_UVC_PARAM_LST));

    typedef apb_uvc_item#(`APB_UVC_PARAM_LST)           item_t;
    typedef bridge_ahb_apb_cov_apb#(`APB_UVC_PARAM_LST) cov_t;

    /* ANALYSIS PORTS */
    uvm_analysis_imp#(item_t, cov_t) m_apb_slave_rsp_imp;

    /* SUBSCRIBER ITEMS */
    item_t m_apb_item;

    /* COVERGROUPS */
    covergroup apb_req_cg;
        option.per_instance = 1;

        cov_apb_paddr   : coverpoint m_apb_item.paddr;
        cov_apb_pprot   : coverpoint m_apb_item.pprot;
        cov_apb_pnse    : coverpoint m_apb_item.pnse;
        cov_apb_pwrite  : coverpoint m_apb_item.pwrite;
        cov_apb_pwdata  : coverpoint m_apb_item.pwdata;
        cov_apb_pstrb   : coverpoint m_apb_item.pstrb;
        cov_apb_prdata  : coverpoint m_apb_item.prdata;
        cov_apb_pslverr : coverpoint m_apb_item.pslverr;
        cov_apb_pwakeup : coverpoint m_apb_item.pwakeup;
        cov_apb_pauser  : coverpoint m_apb_item.pauser;
        cov_apb_pwuser  : coverpoint m_apb_item.pwuser;
        cov_apb_pruser  : coverpoint m_apb_item.pruser;
        cov_apb_pbuser  : coverpoint m_apb_item.pbuser;

    endgroup : apb_req_cg

    /* REGISTRAION MACRO */
    `uvm_component_param_utils(bridge_ahb_apb_cov_apb#(`APB_UVC_PARAM_LST))

    /* CONSTRUCTOR */
    extern function new(string name, uvm_component parent);

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

    /* ANALYSIS PORT METHODS */
    extern virtual function void write(item_t t);

endclass : bridge_ahb_apb_cov_apb

function bridge_ahb_apb_cov_apb::new(string name, uvm_component parent);
    super.new(name, parent);

    // create APB covergroup
    apb_req_cg = new();
    apb_req_cg.set_inst_name("apb_req_cg");

endfunction : new

function void bridge_ahb_apb_cov_apb::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // create analysis ports
    m_apb_slave_rsp_imp = new("m_apb_slave_rsp_imp", this);

endfunction : build_phase

function void bridge_ahb_apb_cov_apb::write(item_t t);
    $cast(m_apb_item, t.clone());
    apb_req_cg.sample();
endfunction : write

`endif // BRIDGE_AHB_APB_COV_APB_SV
