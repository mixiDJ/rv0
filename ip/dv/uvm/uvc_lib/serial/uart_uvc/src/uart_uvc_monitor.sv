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
// Name: uart_uvc_monitor.sv
// Auth: Nikola Lukić
// Date: 11.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_MONITOR_SV
`define UART_UVC_MONITOR_SV

class uart_uvc_monitor extends uvm_monitor;

    typedef virtual uart_uvc_if     vif_t;
    typedef uart_uvc_item           item_t;
    typedef uart_uvc_agent_cfg      cfg_t;

    /* MONITOR ANALYSIS PORTS */
    uvm_analysis_port#(item_t)  m_rx_aport;
    uvm_analysis_port#(item_t)  m_tx_aport;

    /* MONITOR CONFIG */
    cfg_t m_cfg;

    /* MONITOR VIRTUAL INTERFACE */
    vif_t m_vif;

    /* REGISTRATION MACRO */
    `uvm_component_utils(uart_uvc_monitor)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern local task uart_rx_data_collector();
    extern local task uart_tx_data_collector();

endclass : uart_uvc_monitor

function void uart_uvc_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get monitor config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // create analysis ports
    m_rx_aport = new("m_rx_aport", this);
    m_tx_aport = new("m_tx_aport", this);

endfunction : build_phase

task uart_uvc_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
        uart_rx_data_collector();
        uart_tx_data_collector();
    join_none

endtask : run_phase

task uart_uvc_monitor::uart_rx_data_collector();

    forever begin
        time bit_time;
        uint frame_size;
        uint data_bits;
        item_t item = item_t::type_id::create("uart_rx_item", this);

        @(negedge m_vif.rx);

        bit_time   = m_cfg.get_bit_time();
        frame_size = m_cfg.get_frame_size();
        data_bits  = m_cfg.data_bits;

        repeat(frame_size) begin
            #bit_time;
            item.uart_frame >>= 1;
            item.uart_frame[frame_size - 1] = m_vif.rx;
        end

        chk_uart_rx_start_bit : assert(item.uart_frame[0] == 1'b0);

        item.uart_data = item.get_data_bits(data_bits);
        `uvm_info(`gtn, {"\nUART RX:\n", item.sprint()}, UVM_LOW)
        m_rx_aport.write(item);

        // break state condition
        if(|item.uart_frame == 1'b1) begin
            @(posedge m_vif.rx);
            #bit_time;
        end
    end

endtask : uart_rx_data_collector

task uart_uvc_monitor::uart_tx_data_collector();

    forever begin
        time bit_time;
        uint frame_size;
        uint data_bits;
        item_t item = item_t::type_id::create("uart_tx_item", this);

        @(negedge m_vif.tx);

        bit_time   = m_cfg.get_bit_time();
        frame_size = m_cfg.get_frame_size();
        data_bits  = m_cfg.data_bits;

        repeat(frame_size) begin
            #bit_time;
            item.uart_frame >>= 1;
            item.uart_frame[frame_size - 1] = m_vif.tx;
        end

        chk_uart_tx_start_bit : assert(item.uart_frame[0] == 1'b0);

        item.uart_data = item.get_data_bits(data_bits);
        `uvm_info(`gtn, {"\nUART TX:\n", item.sprint()}, UVM_LOW)
        m_tx_aport.write(item);

        // break state condition
        if(|item.uart_frame == 1'b1) begin
            @(posedge m_vif.tx);
            #bit_time;
        end

    end

endtask : uart_tx_data_collector

`endif // UART_UVC_MONITOR_SV
