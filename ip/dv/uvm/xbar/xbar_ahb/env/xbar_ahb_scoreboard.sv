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
// Name: xbar_ahb_scoreboard.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_SCOREBOARD_SV
`define XBAR_AHB_SCOREBOARD_SV

class xbar_ahb_scoreboard #(`XBAR_AHB_PARAMS) extends uvm_scoreboard;

    typedef clk_uvc_item                                clk_seq_item_t;
    typedef ahb_uvc_item#(`AHB_UVC_PARAM_LST)           ahb_seq_item_t;
    typedef xbar_ahb_cfg#(`XBAR_AHB_PARAM_LST)          cfg_t;
    typedef xbar_ahb_scoreboard#(`XBAR_AHB_PARAM_LST)   scoreboard_t;

    /* SCOREBOARD CONFIG */
    cfg_t m_cfg;

    /* SCOREBOARD ANALYSIS PORTS */
    uvm_analysis_imp_clk#(
        clk_seq_item_t,
        scoreboard_t
    ) m_clk_imp;

    uvm_analysis_imp_ahb_master_req#(
        ahb_seq_item_t,
        scoreboard_t
    ) m_ahb_master_req_imp;

    uvm_analysis_imp_ahb_master_rsp#(
        ahb_seq_item_t,
        scoreboard_t
    ) m_ahb_master_rsp_imp;

    uvm_analysis_imp_ahb_slave_req#(
        ahb_seq_item_t,
        scoreboard_t
    ) m_ahb_slave_req_imp;

    uvm_analysis_imp_ahb_slave_rsp#(
        ahb_seq_item_t,
        scoreboard_t
    ) m_ahb_slave_rsp_imp;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(xbar_ahb_scoreboard#(`XBAR_AHB_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);

    /* ANALYSIS PORT METHODS */
    extern virtual function void write_clk(clk_seq_item_t t);
    extern virtual function void write_ahb_master_req(ahb_seq_item_t t);
    extern virtual function void write_ahb_master_rsp(ahb_seq_item_t t);
    extern virtual function void write_ahb_slave_req(ahb_seq_item_t t);
    extern virtual function void write_ahb_slave_rsp(ahb_seq_item_t t);

endclass : xbar_ahb_scoreboard

function void xbar_ahb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void xbar_ahb_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);
endfunction : check_phase

function void xbar_ahb_scoreboard::write_clk(clk_seq_item_t t);

endfunction : write_clk

function void xbar_ahb_scoreboard::write_ahb_master_req(ahb_seq_item_t t);

endfunction : write_ahb_master_req

function void xbar_ahb_scoreboard::write_ahb_master_rsp(ahb_seq_item_t t);

endfunction : write_ahb_master_rsp

function void xbar_ahb_scoreboard::write_ahb_slave_req(ahb_seq_item_t t);

endfunction : write_ahb_slave

function void xbar_ahb_scoreboard::write_ahb_slave_rsp(ahb_seq_item_t t);

endfunction : write_ahb_slave_rsp

`endif // XBAR_AHB_SCOREBOARD_SV
