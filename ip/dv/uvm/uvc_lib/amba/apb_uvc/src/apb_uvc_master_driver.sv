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
// Name: apb_uvc_master_driver.sv
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

`ifndef APB_UVC_MASTER_DRIVER_SV
`define APB_UVC_MASTER_DRIVER_SV

class apb_uvc_master_driver #(`APB_UVC_PARAM_LST) extends uvm_driver#(apb_uvc_item#(`APB_UVC_PARAMS));

    typedef virtual apb_uvc_if#(`APB_UVC_PARAMS)        vif_t;
    typedef apb_uvc_agent_cfg                           cfg_t;

    /* DRIVER CONFIG REF */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_master_driver#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task seq_item_handler();
    extern local task bus_req_handler();

    extern local task reset_handler();
    extern local task bus_reset_handler();

    extern local task bus_par_chk_handler();

endclass : apb_uvc_master_driver

function void apb_uvc_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task apb_uvc_master_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    bus_reset_handler();

    forever begin

        seq_item_port.get_next_item(m_req);
        wait(m_vif.prst_n == 1'b1);

        fork
            seq_item_handler();
            reset_handler();
        join_any
        disable fork;

        seq_item_port.item_done();

    end

endtask : run_phase

task apb_uvc_master_driver::seq_item_handler();
    `uvm_info(`gtn, {"\n", m_req.sprint()}, UVM_HIGH)
    bus_req_handler();
endtask : seq_item_handler

task apb_uvc_master_driver::bus_req_handler();

    if(m_req.pwakeup == 1'b1) begin
        @(posedge m_vif.pclk);
        m_req.pwakeup <= 1'b1;
        bus_par_chk_handler();
    end

    @(posedge m_vif.pclk);
    m_vif.psel    <= 1'b1;
    if(m_cfg.par_chk) m_vif.pselchk <= 1'b0;

    @(posedge m_vif.pclk);
    m_vif.paddr   <= m_req.paddr;
    m_vif.pprot   <= m_req.pprot;
    m_vif.pnse    <= m_req.pnse;
    m_vif.penable <= 1'b1;
    if(m_cfg.par_chk) m_vif.penablechk <= 1'b0;
    m_vif.pwrite  <= m_req.pwrite;
    m_vif.pwdata  <= m_req.pwrite ? m_req.pwdata : m_vif.pwdata;
    m_vif.pstrb   <= m_req.pstrb;
    m_vif.pauser  <= m_req.pauser;
    m_vif.pwuser  <= m_req.pwuser;
    bus_par_chk_handler();

    @(posedge m_vif.pclk iff (m_vif.pready == 1'b1));
    bus_reset_handler();

endtask : bus_req_handler

task apb_uvc_master_driver::reset_handler();
    wait(m_vif.prst_n == 1'b0);
    `uvm_info(`gtn, "RESET SIGNAL ASSERTED", UVM_LOW)
    bus_reset_handler();
endtask : reset_handler

task apb_uvc_master_driver::bus_reset_handler();

    m_vif.paddr      <= {ADDR_WIDTH{1'b0}};
    m_vif.pprot      <= 3'b0;
    m_vif.pnse       <= 1'b0;
    m_vif.psel       <= 1'b0;
    m_vif.penable    <= 1'b0;
    m_vif.pwrite     <= 1'b0;
    m_vif.pwdata     <= 1'b0;
    m_vif.pstrb      <= 1'b0;
    m_vif.pwakeup    <= 1'b0;
    m_vif.pauser     <= {USER_REQ_WIDTH{1'b0}};
    m_vif.pwuser     <= {USER_DATA_WIDTH{1'b0}};

    if(m_cfg.par_chk) begin
        m_vif.paddrchk   <= {ADDR_CHK_WIDTH{1'b1}};
        m_vif.pctrlchk   <= 1'b1;
        m_vif.pselchk    <= 1'b1;
        m_vif.penablechk <= 1'b1;
        m_vif.pwdatachk  <= {DATA_CHK_WIDTH{1'b1}};
        m_vif.pstrbchk   <= 1'b1;
        m_vif.pwakeupchk <= 1'b1;
        m_vif.pauserchk  <= {USER_REQ_CHK_WIDTH{1'b1}};
        m_vif.pwuserchk  <= {USER_DATA_CHK_WIDTH{1'b1}};
    end

endtask : bus_reset_handler

task apb_uvc_master_driver::bus_par_chk_handler();

    if(m_cfg.par_chk) begin

        for(int i = 0; i < ADDR_CHK_WIDTH; ++i) begin
            m_vif.paddrchk[i] <= ~^m_req.paddr[8*i +: 8];
        end

        m_vif.pctrlchk   <= ~^{m_req.pprot, m_req.pwrite, m_req.pnse};
        m_vif.pstrbchk   <= ~^m_req.pstrb;
        m_vif.pwakeupchk <= ~m_req.pwakeup;

        if(m_vif.pwrite == 1'b0) begin

            for(int i = 0; i < DATA_CHK_WIDTH; ++i) begin
                m_vif.pwdatachk[i] <= ~^m_req.pwdata[8*i +: 8];
            end

        end

        for(int i = 0; i < USER_REQ_CHK_WIDTH; ++i) begin
            m_vif.pauserchk[i] <= ~^m_req.pauser[8*i +: 8];
        end

        for(int i = 0; i < USER_DATA_CHK_WIDTH; ++i) begin
            m_vif.pwuserchk[i] <= ~^m_req.pwuser[8*i +: 8];
        end

    end

endtask : bus_par_chk_handler

`endif // APB_UVC_MASTER_DRIVER_SV
