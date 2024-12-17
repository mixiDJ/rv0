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
// Name: uart_apb_vseq_smoke.sv
// Auth: Nikola Lukić
// Date: 24.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_APB_VSEQ_SMOKE_SV
`define UART_APB_VSEQ_SMOKE_SV

class uart_apb_vseq_smoke extends uart_apb_vseq_base;

    /* VIRTUAL SEQUENCE FIELDS */
    rand uint tx_seq_cnt;
    rand uint rx_seq_cnt;

    rand time dly;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_tx_seq_cnt { tx_seq_cnt inside {[2:5]}; }
    constraint c_rx_seq_cnt { rx_seq_cnt inside {[2:5]}; }

    constraint c_dly { dly inside {[100ns:100us]}; }

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_apb_vseq_smoke)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(uart_apb_vsequencer)

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : uart_apb_vseq_smoke

task uart_apb_vseq_smoke::body();
    apb_seq_base_t      apb_seq_base;
    uart_apb_vseq_cfg   vseq_cfg;
    uart_seq_base_t     uart_seq_base;

    `uvm_do_on(vseq_cfg, p_sequencer)

    tx_seq_cnt.rand_mode(0);
    rx_seq_cnt.rand_mode(0);

    repeat(tx_seq_cnt) begin
        this.randomize();
        #dly;
        `uvm_do_on(uart_seq_base, p_sequencer.m_uart_seqr)
    end

    repeat(tx_seq_cnt) begin
        `uvm_do_on_with(
            apb_seq_base,
            p_sequencer.m_apb_seqr,
            {
                paddr  == 'h1600_0000;
                pwrite == 1'b0;
            }
        )
    end

    repeat(rx_seq_cnt) begin
        this.randomize();
        #dly;
        `uvm_do_on_with(
            apb_seq_base,
            p_sequencer.m_apb_seqr,
            {
                paddr        == 'h1600_0000;
                pwrite       == 1'b1;
                pwdata[31:8] == 'h0;
                pstrb        == 'b0001;
            }
        )
    end

endtask : body

`endif // UART_APB_VSEQ_SMOKE_SV
