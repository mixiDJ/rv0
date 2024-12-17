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
// Name: ahb_uvc_master_driver.sv
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

`ifndef AHB_UVC_MASTER_DRIVER_SV
`define AHB_UVC_MASTER_DRIVER_SV

class ahb_uvc_master_driver #(`AHB_UVC_PARAM_LST) extends uvm_driver#(ahb_uvc_item#(`AHB_UVC_PARAMS));

    typedef virtual ahb_uvc_if#(`AHB_UVC_PARAMS)    vif_t;
    typedef ahb_uvc_agent_cfg                       cfg_t;
    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)          item_t;

    /* DRIVER CONFIG OBJECT */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_req;

    /* DRIVER SEQUENCE ITEM FIFO */
    REQ m_req_fifo [$];

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(ahb_uvc_master_driver#(`AHB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task seq_item_handler();
    extern local task bus_req_handler();
    extern local task seq_item_wdata_handler(bit [DATA_WIDTH-1:0] wdata);

    extern local task reset_handler();
    extern local task bus_reset_handler();

endclass : ahb_uvc_master_driver

function void ahb_uvc_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get driver config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get driver virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task ahb_uvc_master_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    bus_reset_handler();

    forever begin

        wait(m_vif.hrst_n == 1'b1);

        fork
            begin
                seq_item_handler();
            end
            begin
                bus_req_handler();
            end
            begin
                reset_handler();
            end
        join_any
        disable fork;

    end

endtask : run_phase

task ahb_uvc_master_driver::seq_item_handler();

    forever begin
        seq_item_port.get_next_item(m_req);
        m_req_fifo.push_back(item_t'(m_req.clone()));
        seq_item_port.item_done();
    end

endtask : seq_item_handler

task ahb_uvc_master_driver::bus_req_handler();

    item_t req;
    forever begin

        @(posedge m_vif.hclk iff (m_vif.hreadyout == 1'b1 && m_vif.hrst_n == 1'b1));

        if(m_req_fifo.size() == 0) m_vif.htrans <= 1'b0;
        else begin

            req = m_req_fifo.pop_front();

            `uvm_info(`gtn, {"\n", req.sprint()}, UVM_HIGH)

            m_vif.haddr     <= req.haddr;
            m_vif.hburst    <= req.hburst;
            m_vif.hmastlock <= req.hmastlock;
            m_vif.hprot     <= req.hprot;
            m_vif.hsize     <= req.hsize;
            m_vif.hnonsec   <= req.hnonsec;
            m_vif.hexcl     <= req.hexcl;
            m_vif.hmaster   <= req.hmaster;
            m_vif.htrans    <= req.htrans;
            m_vif.hwstrb    <= req.hwstrb;
            m_vif.hwrite    <= req.hwrite;
            m_vif.hsel      <= req.hsel;
            m_vif.hauser    <= req.hauser;
            m_vif.hwuser    <= req.hwuser;

            if(req.hwrite == 1'b1) begin
                fork
                    seq_item_wdata_handler(req.hwdata);
                join_none
            end

        end
    end

endtask : bus_req_handler

task ahb_uvc_master_driver::seq_item_wdata_handler(bit [DATA_WIDTH-1:0] wdata);
    @(posedge m_vif.hclk);
    m_vif.hwdata <= wdata;
endtask : seq_item_wdata_handler

task ahb_uvc_master_driver::reset_handler();

    @(negedge m_vif.hrst_n);
    `uvm_info(`gtn, "RESET SIGNAL ASSERTED", UVM_HIGH)

    m_req_fifo.delete();

    bus_reset_handler();

endtask : reset_handler

task ahb_uvc_master_driver::bus_reset_handler();
    m_vif.haddr     <= {ADDR_WIDTH{1'b0}};
    m_vif.hburst    <= {HBURST_WIDTH{1'b0}};
    m_vif.hmastlock <= 1'b0;
    m_vif.hprot     <= {HPROT_WIDTH{1'b0}};
    m_vif.hsize     <= 3'b0;
    m_vif.hnonsec   <= 1'b0;
    m_vif.hexcl     <= 1'b0;
    m_vif.hmaster   <= {HMASTER_WIDTH{1'b0}};
    m_vif.htrans    <= 2'b0;
    m_vif.hwdata    <= {DATA_WIDTH{1'b0}};
    m_vif.hwstrb    <= {STRB_WIDTH{1'b0}};
    m_vif.hwrite    <= 1'b0;
    m_vif.hsel      <= 1'b0;
    m_vif.hauser    <= {USER_REQ_WIDTH{1'b0}};
    m_vif.hwuser    <= {USER_DATA_WIDTH{1'b0}};
endtask : bus_reset_handler

`endif // AHB_UVC_MASTER_DRIVER_SV
