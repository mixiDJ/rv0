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
// Name: ahb_uvc_slave_driver.sv
// Auth: Nikola Lukić
// Date: 28.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_SLAVE_DRIVER_SV
`define AHB_UVC_SLAVE_DRIVER_SV

class ahb_uvc_slave_driver #(`AHB_UVC_PARAM_LST) extends uvm_driver#(ahb_uvc_item#(`AHB_UVC_PARAMS));

    typedef virtual ahb_uvc_if#(`AHB_UVC_PARAMS)    vif_t;
    typedef ahb_uvc_agent_cfg                       cfg_t;
    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)          item_t;

    /* DRIVER CONFIG OBJECT */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    RSP m_rsp;

    /* DRIVER SEQUENCE ITEM FIFO */
    RSP m_rsp_fifo [$];

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(ahb_uvc_slave_driver#(`AHB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task seq_item_handler();
    extern local task bus_rsp_handler();

    extern local task reset_handler();
    extern local task bus_reset_handler();

endclass : ahb_uvc_slave_driver

function void ahb_uvc_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get driver config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get driver virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task ahb_uvc_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    bus_reset_handler();

    fork
        bus_rsp_handler();
    join_none

    forever begin

        wait(m_vif.hrst_n == 1'b1);
        seq_item_port.get_next_item(m_rsp);

        fork
            begin
                seq_item_handler();
            end
            begin
                reset_handler();
            end
        join_any

        seq_item_port.item_done();

    end

endtask : run_phase

task ahb_uvc_slave_driver::seq_item_handler();
    m_rsp_fifo.push_back(m_rsp);
    `uvm_info(`gtn, {"\nSEQ ITEM:\n", m_rsp.sprint()}, UVM_HIGH)
endtask : seq_item_handler

task ahb_uvc_slave_driver::bus_rsp_handler();

    item_t req = item_t::type_id::create("req", this);
    item_t rsp;

    forever begin

        @(
            posedge m_vif.hclk
            iff (m_vif.htrans inside {HTRANS_NONSEQ, HTRANS_SEQ} && m_vif.hsel == 1'b1)
        );

        req.hwrite = m_vif.hwrite;

        if(m_rsp_fifo.size() == 0) begin
            m_vif.hreadyout <= 1'b0;
            wait(m_rsp_fifo.size() > 0);
        end
        else begin

            rsp = m_rsp_fifo.pop_front();

            req.haddr  <= m_vif.haddr;
            req.hwrite <= m_vif.hwrite;

            m_vif.hreadyout <= 1'b0;
            repeat(rsp.rsp_dly) @(posedge m_vif.hclk);

            if(req.hwrite == 1'b0) m_vif.hrdata <= rsp.hrdata;
            m_vif.hreadyout <= 1'b1;
            m_vif.hresp     <= rsp.hresp;
            m_vif.hexokay   <= rsp.hexokay;
            m_vif.hruser    <= rsp.hruser;
            m_vif.hbuser    <= rsp.hbuser;

        end

    end

endtask : bus_rsp_handler

task ahb_uvc_slave_driver::reset_handler();
    wait(m_vif.hrst_n == 1'b0);
    `uvm_info(`gtn, "RESET SIGNAL ASSERTED", UVM_HIGH)
    bus_reset_handler();
endtask : reset_handler

task ahb_uvc_slave_driver::bus_reset_handler();
    m_vif.hreadyout <= 1'b1;
    m_vif.hrdata    <= {DATA_WIDTH{1'b0}};
    m_vif.hresp     <= 1'b0;
    m_vif.hexokay   <= 1'b1;
    m_vif.hruser    <= {USER_DATA_WIDTH{1'b0}};
    m_vif.hbuser    <= {USER_RESP_WIDTH{1'b0}};
endtask : bus_reset_handler

`endif // AHB_UVC_SLAVE_DRIVER_SV
