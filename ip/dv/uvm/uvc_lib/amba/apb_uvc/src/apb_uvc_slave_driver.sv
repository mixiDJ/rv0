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
// Name: apb_uvc_slave_driver.sv
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

`ifndef APB_UVC_SLAVE_DRIVER_SV
`define APB_UVC_SLAVE_DRIVER_SV

class apb_uvc_slave_driver #(`APB_UVC_PARAM_LST) extends uvm_driver#(apb_uvc_item#(`APB_UVC_PARAMS));

    typedef virtual apb_uvc_if#(`APB_UVC_PARAMS)        vif_t;
    typedef apb_uvc_agent_cfg                           cfg_t;

    /* DRIVER CONFIG REF */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_rsp;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_slave_driver#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task seq_item_handler();
    extern local task bus_rsp_handler();

    extern local task reset_handler();
    extern local task bus_reset_handler();

    extern local task bus_par_chk_handler();

endclass : apb_uvc_slave_driver

function void apb_uvc_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task apb_uvc_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    bus_reset_handler();

    forever begin : slave_driver_run_phase_blk

        seq_item_port.get_next_item(m_rsp);
        wait(m_vif.prst_n == 1'b1);

        fork
            seq_item_handler();
            reset_handler();
        join_any
        disable fork;

        seq_item_port.item_done();

    end

endtask : run_phase

task apb_uvc_slave_driver::seq_item_handler();
    `uvm_info(`gtn, {"\n", m_rsp.sprint()}, UVM_HIGH)
    bus_rsp_handler();
endtask : seq_item_handler

task apb_uvc_slave_driver::bus_rsp_handler();

    @(posedge m_vif.pclk iff (m_vif.psel == 1'b1 && m_vif.penable == 1'b1));
    repeat(m_rsp.rsp_dly) @(posedge m_vif.pclk);

    m_vif.pready  <= 1'b1;
    m_vif.prdata  <= m_vif.pwrite ? {DATA_WIDTH{1'b0}} : m_rsp.prdata;
    m_vif.pslverr <= m_rsp.pslverr;
    m_vif.pruser  <= m_rsp.pruser;
    m_vif.pbuser  <= m_rsp.pbuser;
    bus_par_chk_handler();

    @(posedge m_vif.pclk);
    bus_reset_handler();

endtask : bus_rsp_handler

task apb_uvc_slave_driver::reset_handler();
    wait(m_vif.prst_n == 1'b0);
    `uvm_info(`gtn, "RESET SIGNAL ASSRTED", UVM_HIGH)
    bus_reset_handler();
endtask : reset_handler

task apb_uvc_slave_driver::bus_reset_handler();

    m_vif.pready <= 1'b0;
    m_vif.prdata <= {DATA_WIDTH{1'b0}};
    m_vif.pslverr <= 1'b0;
    m_vif.pruser  <= {USER_DATA_WIDTH{1'b0}};
    m_vif.pbuser  <= {USER_RESP_WIDTH{1'b0}};

    if(m_cfg.par_chk) begin
        m_vif.preadychk  <= 1'b1;
        m_vif.prdatachk  <= {DATA_CHK_WIDTH{1'b1}};
        m_vif.pslverrchk <= 1'b1;
        m_vif.pruserchk  <= {USER_DATA_CHK_WIDTH{1'b1}};
        m_vif.pbuserchk  <= {USER_RESP_CHK_WIDTH{1'b1}};
    end

endtask : bus_reset_handler

task apb_uvc_slave_driver::bus_par_chk_handler();

    if(m_cfg.par_chk) begin

        m_vif.preadychk <= 1'b0;
        m_vif.pslverrchk <= ~m_rsp.pslverr;

        if(m_vif.pwrite == 1'b0) begin

            for(int i = 0; i < DATA_CHK_WIDTH; ++i) begin
                m_vif.prdatachk[i] <= ~^m_rsp.prdata[8*i +: 8];
            end

            for(int i = 0; i < USER_DATA_CHK_WIDTH; ++i) begin
                m_vif.pruserchk[i] <= ~^m_rsp.pruser[8*i +: 8];
            end

        end

        for(int i = 0; i < USER_RESP_CHK_WIDTH; ++i) begin
            m_vif.pbuserchk[i] <= ~^m_rsp.pbuser[8*i +: 8];
        end

    end

endtask : bus_par_chk_handler

`endif // APB_UVC_SLAVE_DRIVER_SV
