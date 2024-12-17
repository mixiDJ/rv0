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
// Name: clk_uvc_driver.sv
// Auth: Nikola Lukić
// Date: 03.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_DRIVER_SV
`define CLK_UVC_DRIVER_SV

class clk_uvc_driver extends uvm_driver#(clk_uvc_item);

    typedef virtual clk_uvc_if  vif_t;
    typedef clk_uvc_agent_cfg   cfg_t;

    /* DRIVER CONFIG REF */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_component_utils(clk_uvc_driver)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task clk_cycle_handler();
    extern local task reset_handler();

endclass : clk_uvc_driver

function void clk_uvc_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get driver config from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task clk_uvc_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
        clk_cycle_handler();
        reset_handler();
    join_none

endtask : run_phase

task clk_uvc_driver::clk_cycle_handler();
    time clk_period;
    real clk_duty_cycle;

    // wait for clock phase delay
    m_vif.clk <= 1'b0;
    #(m_cfg.clk_phase * m_cfg.clk_period / 360.0);

    forever begin

        clk_period = m_cfg.clk_period;
        clk_duty_cycle = m_cfg.clk_duty_cycle;

        if(m_cfg.clk_enable == 1'b1) begin
            m_vif.clk <= 1'b1;
            #(clk_period * clk_duty_cycle);
            m_vif.clk <= 1'b0;
            #(clk_period * (1.0 - clk_duty_cycle));
        end
        else begin
            m_vif.clk <= 1'b0;
            #(clk_period);
        end

    end

endtask : clk_cycle_handler

task clk_uvc_driver::reset_handler();

    if(m_cfg.rst_init) begin
        m_vif.rst   <= 1'b1;
        m_vif.rst_n <= 1'b0;

        repeat(m_cfg.rst_init_delay) @(posedge m_vif.clk);
        #(m_cfg.rst_assert_delay);

        m_vif.rst   <= 1'b0;
        m_vif.rst_n <= 1'b1;
    end
    else begin
        m_vif.rst   <= 1'b0;
        m_vif.rst_n <= 1'b1;
    end

    forever begin

        seq_item_port.get_next_item(m_req);

        repeat(m_req.rst_dly) @(posedge m_vif.clk);
        #(m_cfg.rst_assert_delay);

        case(m_req.typ)
            RST_ASSERT: begin
                m_vif.rst   <= 1'b1;
                m_vif.rst_n <= 1'b0;
            end
            RST_DEASSERT: begin
                m_vif.rst   <= 1'b0;
                m_vif.rst_n <= 1'b1;
            end
        endcase

        seq_item_port.item_done();

    end

endtask : reset_handler

`endif // CLK_UVC_DRIVER_SV
