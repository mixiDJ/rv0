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
// Name: uart_apb_vseq_cfg.sv
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

`ifndef UART_APB_VSEQ_CFG_SV
`define UART_APB_VSEQ_CFG_SV

class uart_apb_vseq_cfg extends uart_apb_vseq_base;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_apb_vseq_cfg)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(uart_apb_vsequencer)

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : uart_apb_vseq_cfg

task uart_apb_vseq_cfg::body();
    apb_seq_base_t apb_seq_base;
    uart_uvc_agent_cfg cfg;

    bit [7:0] lcr_data;

    cfg = p_sequencer.m_cfg.uart_env_cfg.agent_cfg;

    lcr_data[7]   = cfg.par_stck;
    lcr_data[6:5] = cfg.data_bits - 5;
    lcr_data[4]   = 1;
    lcr_data[3]   = cfg.stop_bits - 1;
    lcr_data[2]   = cfg.par_typ;
    lcr_data[1]   = cfg.par_bit;
    lcr_data[0]   = 0;

    `uvm_do_on_with(
        apb_seq_base,
        p_sequencer.m_apb_seqr,
        {
            paddr  == 'h1600_002c;
            pwdata == {24'h0, lcr_data};
            pwrite == 1'b1;
            pstrb  == 'b0001;
        }
    )

    `uvm_do_on_with(
        apb_seq_base,
        p_sequencer.m_apb_seqr,
        {
            paddr  == 'h1600_0024;
            pwdata == 'd326;
            pwrite == 1'b1;
            pstrb  == 'b0011;
        }
    )

    `uvm_do_on_with(
        apb_seq_base,
        p_sequencer.m_apb_seqr,
        {
            paddr  == 'h1600_0030;
            pwdata == 'h0301;
            pwrite == 1'b1;
            pstrb  == 'b0011;
        }
    )

endtask : body

`endif // UART_APB_VSEQ_CFG_SV
