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
// Name: bridge_ahb_apb_scoreboard.sv
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

`ifndef BRIDGE_AHB_APB_SCOREBOARD_SV
`define BRIDGE_AHB_APB_SCOREBOARD_SV

class bridge_ahb_apb_scoreboard #(`BRIDGE_AHB_APB_PARAMS) extends uvm_scoreboard;

    typedef ahb_uvc_item#(`AHB_UVC_PARAM_LST)                       ahb_seq_item_t;
    typedef apb_uvc_item#(`APB_UVC_PARAM_LST)                       apb_seq_item_t;
    typedef clk_uvc_item                                            clk_seq_item_t;
    typedef bridge_ahb_apb_scoreboard#(`BRIDGE_AHB_APB_PARAM_LST)   scoreboard_t;
    typedef bridge_ahb_apb_cfg                                      cfg_t;

    /* SCOREBOARD CONFIG */
    cfg_t m_cfg;

    /* SCOREBOARD ANALYSIS PORTS */
    uvm_analysis_imp_ahb#(
        ahb_seq_item_t,
        scoreboard_t
    ) m_ahb_master_rsp_imp;

    uvm_analysis_imp_apb#(
        apb_seq_item_t,
        scoreboard_t
    ) m_apb_slave_rsp_imp;

    uvm_analysis_imp_clk_ahb#(
        clk_seq_item_t,
        scoreboard_t
    ) m_clk_imp_0;

    uvm_analysis_imp_clk_apb#(
        clk_seq_item_t,
        scoreboard_t
    ) m_clk_imp_1;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(bridge_ahb_apb_scoreboard#(`BRIDGE_AHB_APB_PARAM_LST))
    `uvm_component_new

    /* SCOREBOARD DATA */
    apb_seq_item_t apb_rsp_fifo [$];

    ahb_seq_item_t ahb_seq_item;
    apb_seq_item_t apb_seq_item;

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);

    /* ANALYSIS PORT METHODS */
    extern virtual function void write_ahb(ahb_seq_item_t t);
    extern virtual function void write_apb(apb_seq_item_t t);
    extern virtual function void write_clk_ahb(clk_seq_item_t t);
    extern virtual function void write_clk_apb(clk_seq_item_t t);

endclass : bridge_ahb_apb_scoreboard

function void bridge_ahb_apb_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get scoreboard config from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // create analysis ports
    m_ahb_master_rsp_imp = new("m_ahb_master_rsp_imp", this);
    m_apb_slave_rsp_imp  = new("m_apb_slave_rsp_imp", this);
    m_clk_imp_0          = new("m_clk_imp_0", this);
    m_clk_imp_1          = new("m_clk_imp_1", this);

endfunction : build_phase

function void bridge_ahb_apb_scoreboard::write_ahb(ahb_seq_item_t t);

    //if(t.hsel == 1'b0) return;

    $cast(ahb_seq_item, t.clone());
    `uvm_info(`gtn, {"\nAHB RSP\n", ahb_seq_item.sprint()}, UVM_HIGH)

    chk_apb_resp_valid : assert(apb_rsp_fifo.size() != 0);

    apb_seq_item = apb_rsp_fifo.pop_front();

    `uvm_info(`gtn, {"\nAHB:\n", ahb_seq_item.sprint(), "\nAPB:\n", apb_seq_item.sprint()}, UVM_HIGH)

    chk_addr_equal  : assert(ahb_seq_item.haddr  == apb_seq_item.paddr)
    else begin
        `uvm_warning(`gtn, {"\n", ahb_seq_item.sprint(), "\n\n", apb_seq_item.sprint()})
    end

    chk_write_equal : assert(ahb_seq_item.hwrite == apb_seq_item.pwrite);
    if(ahb_seq_item.hwrite) begin
        chk_wdata_equal : assert(ahb_seq_item.hwdata == apb_seq_item.pwdata);
    end
    else begin
        chk_rdata_equal : assert(ahb_seq_item.hrdata == apb_seq_item.prdata);
    end
    chk_strb_equal : assert(ahb_seq_item.hwstrb == apb_seq_item.pstrb);
    chk_resp_equal : assert(ahb_seq_item.hresp  == apb_seq_item.pslverr);

    if(USER_REQ_WIDTH > 0) begin
        chk_auser_equal : assert(ahb_seq_item.hauser == apb_seq_item.pauser);
    end

    if(USER_DATA_WIDTH > 0) begin
        chk_wuser_equal : assert(ahb_seq_item.hwuser == apb_seq_item.pwuser)
        else `uvm_warning(`gtn, {"\nAHB RSP:\n", ahb_seq_item.sprint(), "\nAPB RSP:\n", apb_seq_item.sprint()});
        chk_ruser_equal : assert(ahb_seq_item.hruser == apb_seq_item.pruser)
        else `uvm_warning(`gtn, {"\nAHB RSP:\n", ahb_seq_item.sprint(), "\nAPB RSP:\n", apb_seq_item.sprint()});
    end

    if(USER_RESP_WIDTH > 0) begin
        chk_buser_equal : assert(ahb_seq_item.hbuser == apb_seq_item.pbuser);
    end

endfunction : write_ahb

function void bridge_ahb_apb_scoreboard::write_apb(apb_seq_item_t t);
    $cast(apb_seq_item, t.clone());
    apb_rsp_fifo.push_back(apb_seq_item);
endfunction : write_apb

function void bridge_ahb_apb_scoreboard::write_clk_ahb(clk_seq_item_t t);

endfunction : write_clk_ahb

function void bridge_ahb_apb_scoreboard::write_clk_apb(clk_seq_item_t t);
    if(t.typ == RST_ASSERT) apb_rsp_fifo.delete();
endfunction : write_clk_apb

function void bridge_ahb_apb_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);
    chk_apb_fifo_empty : assert(apb_rsp_fifo.size() == 0)
    else `uvm_warning(`gtn, $sformatf("\napb_rsp_fifo.size()=%0d", apb_rsp_fifo.size()))
endfunction : check_phase

`endif // BRIDGE_AHB_APB_SCOREBOARD_SV
