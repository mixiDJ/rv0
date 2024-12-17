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
// Source location:
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: uart_uvc_driver.sv
// Auth: Nikola Lukić
// Date: 10.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_DRIVER_SV
`define UART_UVC_DRIVER_SV

class uart_uvc_driver extends uvm_driver#(uart_uvc_item);

    typedef virtual uart_uvc_if     vif_t;
    typedef uart_uvc_agent_cfg      cfg_t;
    typedef uart_uvc_item           item_t;

    /* DRIVER CONFIG REF */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_component_utils(uart_uvc_driver)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task seq_item_handler();

endclass : uart_uvc_driver

function void uart_uvc_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

endfunction : build_phase

task uart_uvc_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    m_vif.tx <= 1'b1;

    forever begin
        seq_item_port.get_next_item(m_req);
        seq_item_handler();
        seq_item_port.item_done();
    end

endtask : run_phase

task uart_uvc_driver::seq_item_handler();
    time bit_time = m_cfg.get_bit_time();
    uint frame_size = m_cfg.get_frame_size();

    `uvm_info(`gtn, {"\nUART FRAME:\n", m_req.sprint()}, UVM_LOW)
    `uvm_info(`gtn, $sformatf("\nUART FRAME SIZE: %0d", frame_size), UVM_LOW)

    repeat(frame_size) begin
        m_vif.tx <= m_req.uart_frame[0];
        m_req.uart_frame >>= 1;
        #bit_time;
    end

    m_vif.tx <= 1'b1;

endtask : seq_item_handler

`endif // UART_UVC_DRIVER_SV
