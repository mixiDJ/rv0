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
// Name: clk_uvc_seq_rst.sv
// Auth: Nikola Lukić
// Date: 17.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_SEQ_RST_SV
`define CLK_UVC_SEQ_RST_SV

class clk_uvc_seq_rst extends uvm_sequence#(clk_uvc_item);

    /* SEQUENCE FIELDS */
    rand dly_typ_e  rst_dly_typ;
    rand int        rst_dly;
    rand dly_typ_e  rst_len_typ;
    rand int        rst_len;

    /* SEQUENCE CONSTRAINTS */
    constraint c_rst_dly     { `DELAY_RANGE_CONSTRAINT(rst_dly, rst_dly_typ) }
    constraint c_rst_len_typ { rst_len_typ != DLY_ZERO;                      }
    constraint c_rst_len     { `DELAY_RANGE_CONSTRAINT(rst_len, rst_len_typ) }

    /* SEQUENCE ITEMS */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(clk_uvc_seq_rst)
        `uvm_field_enum(dly_typ_e, rst_dly_typ, UVM_DEFAULT)
        `uvm_field_int (           rst_dly,     UVM_DEFAULT)
        `uvm_field_enum(dly_typ_e, rst_len_typ, UVM_DEFAULT)
        `uvm_field_int (           rst_len,     UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(clk_uvc_sequencer)

    /* SEQUENCE BODY TASK */
    extern virtual task body();

endclass : clk_uvc_seq_rst

task clk_uvc_seq_rst::body();

    `uvm_do_with(
        m_req,
        {
            rst_dly_typ == local::rst_dly_typ;
            rst_dly     == local::rst_dly;
            typ         == local::RST_ASSERT;
        }
    )

    `uvm_do_with(
        m_req,
        {
            rst_dly_typ == local::rst_len_typ;
            rst_dly     == local::rst_len;
            typ         == local::RST_DEASSERT;
        }
    )

endtask : body

`endif // CLK_UVC_SEQ_RST_SV
