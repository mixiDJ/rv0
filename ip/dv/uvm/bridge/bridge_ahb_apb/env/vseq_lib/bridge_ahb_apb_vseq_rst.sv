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
// Name: bridge_ahb_apb_vseq_rst.sv
// Auth: Nikola Lukić
// Date: 16.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_VSEQ_RST_SV
`define BRIDGE_AHB_APB_VSEQ_RST_SV

class bridge_ahb_apb_vseq_rst #(`BRIDGE_AHB_APB_PARAMS) extends bridge_ahb_apb_vseq_base#(`BRIDGE_AHB_APB_PARAM_LST);

    /* VIRTUAL SEQUENCE FIELDS */
    rand int unsigned seq_cnt;
    rand int unsigned rst_cnt;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_seq_cnt { soft seq_cnt inside {[1:20]}; }
    constraint c_rst_cnt { soft rst_cnt inside {[1:5]};  }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(bridge_ahb_apb_vseq_rst#(`BRIDGE_AHB_APB_PARAM_LST))
        `uvm_field_int(seq_cnt, UVM_DEFAULT)
        `uvm_field_int(rst_cnt, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : bridge_ahb_apb_vseq_rst

task bridge_ahb_apb_vseq_rst::body();

    repeat(seq_cnt) begin

        `uvm_start_on_with(
            ahb_seq_base,
            p_sequencer.m_ahb_master_seqr,
            {
                hnonsec == 1'b0;
                hexcl   == 1'b0;
            }
        )

        `uvm_start_on_with(
            apb_seq_base,
            p_sequencer.m_apb_slave_seqr,
            { pslverr == 1'b0; }
        )

    end

    `uvm_start_on(ahb_seq_base, p_sequencer.m_ahb_master_seqr)
    #100ns;

    fork
        begin
            `uvm_start_on_with(
                clk_seq_rst,
                p_sequencer.m_clk_seqr[0],
                { rst_dly == 0; }
            )
        end
        begin
            `uvm_start_on_with(
                clk_seq_rst,
                p_sequencer.m_clk_seqr[1],
                { rst_dly == 0; }
            )
        end
    join

    repeat(seq_cnt) begin

        `uvm_start_on_with(
            ahb_seq_base,
            p_sequencer.m_ahb_master_seqr,
            {
                hnonsec == 1'b0;
                hexcl   == 1'b0;
            }
        )

        `uvm_start_on_with(
            apb_seq_base,
            p_sequencer.m_apb_slave_seqr,
            { pslverr == 1'b0; }
        )

    end

endtask : body

`endif // BRIDGE_AHB_APB_VSEQ_RST_SV
