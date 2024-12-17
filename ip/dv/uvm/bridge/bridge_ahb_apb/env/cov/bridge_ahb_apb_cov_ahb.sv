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
// Name: bridge_ahb_apb_cov_ahb.sv
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

`ifndef BRIDGE_AHB_APB_COV_AHB_SV
`define BRIDGE_AHB_APB_COV_AHB_SV

class bridge_ahb_apb_cov_ahb #(`AHB_UVC_PARAMS) extends uvm_subscriber#(ahb_uvc_item#(`AHB_UVC_PARAM_LST));

    typedef ahb_uvc_item#(`AHB_UVC_PARAM_LST)           item_t;
    typedef bridge_ahb_apb_cov_ahb#(`AHB_UVC_PARAM_LST) cov_t;

    /* ANALYSIS PORTS */
    uvm_analysis_imp#(item_t, cov_t) m_ahb_master_rsp_imp;

    /* SUBSCRIBER ITEMS */
    item_t m_ahb_item;

    /* COVERGROUPS */
    covergroup ahb_req_cg;
        option.per_instance = 1;

        cov_ahb_haddr     : coverpoint m_ahb_item.haddr;
        cov_ahb_hburst    : coverpoint m_ahb_item.hburst {
            bins hburst_single = {3'h0};
            bins hburst_incr   = {3'h1};
            bins hburst_wrap4  = {3'h2};
            bins hburst_incr4  = {3'h3};
            bins hburst_wrap8  = {3'h4};
            bins hburst_incr8  = {3'h5};
            bins hburst_wrap16 = {3'h6};
            bins hburst_incr16 = {3'h7};
        }
        cov_ahb_hmastlock : coverpoint m_ahb_item.hmastlock;
        cov_ahb_hprot     : coverpoint m_ahb_item.hprot;
        cov_ahb_hsize     : coverpoint m_ahb_item.hsize {
            bins hsize_byte   = {3'h0};
            bins hsize_half   = {3'h1};
            bins hsize_word   = {3'h2};
            bins hsize_double = {3'h3};
            ignore_bins other = {[3'h4:3'h7]};
        }
        cov_ahb_hnonsec   : coverpoint m_ahb_item.hnonsec;
        cov_ahb_hexcl     : coverpoint m_ahb_item.hexcl;
        cov_ahb_hmaster   : coverpoint m_ahb_item.hmaster;
        cov_ahb_htrans    : coverpoint m_ahb_item.htrans {
            bins htrans_nonseq = {2'b10};
            bins htrans_seq    = {2'b11};
            ignore_bins other  = {2'b00, 2'b01};
        }
        cov_ahb_hwdata    : coverpoint m_ahb_item.hwdata;
        cov_ahb_hwstrb    : coverpoint m_ahb_item.hwstrb;
        cov_ahb_hwrite    : coverpoint m_ahb_item.hwrite;
        cov_ahb_hsel      : coverpoint m_ahb_item.hsel;
        cov_ahb_hrdata    : coverpoint m_ahb_item.hrdata;
        cov_ahb_hresp     : coverpoint m_ahb_item.hresp {
            bins hresp_okay  = {1'b0};
            bins hresp_error = {1'b1};
        }
        cov_ahb_hexokay   : coverpoint m_ahb_item.hexokay;
        cov_ahb_hauser    : coverpoint m_ahb_item.hauser;
        cov_ahb_hwuser    : coverpoint m_ahb_item.hwuser;
        cov_ahb_hruser    : coverpoint m_ahb_item.hruser;
        cov_ahb_hbuser    : coverpoint m_ahb_item.hbuser;

    endgroup : ahb_req_cg

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(bridge_ahb_apb_cov_ahb#(`AHB_UVC_PARAM_LST))

    /* CONSTRUCTOR */
    extern function new(string name, uvm_component parent);

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

    /* ANALYSIS PORT METHODS */
    extern virtual function void write(item_t t);

endclass : bridge_ahb_apb_cov_ahb

function bridge_ahb_apb_cov_ahb::new(string name, uvm_component parent);
    super.new(name, parent);

    // create AHB covergroup
    ahb_req_cg = new();
    ahb_req_cg.set_inst_name("ahb_req_cg");

endfunction : new

function void bridge_ahb_apb_cov_ahb::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // create analysis ports
    m_ahb_master_rsp_imp = new("m_ahb_master_rsp_imp", this);

endfunction : build_phase

function void bridge_ahb_apb_cov_ahb::write(item_t t);
    $cast(m_ahb_item, t.clone());
    ahb_req_cg.sample();
endfunction : write

`endif // BRIDGE_AHB_APB_COV_AHB_SV
