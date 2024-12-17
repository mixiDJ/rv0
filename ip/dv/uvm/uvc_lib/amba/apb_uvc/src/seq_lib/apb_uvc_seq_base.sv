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
// Name: apb_uvc_seq_base.sv
// Auth: Nikola Lukić
// Date: 14.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_SEQ_BASE_SV
`define APB_UVC_SEQ_BASE_SV

class apb_uvc_seq_base #(`APB_UVC_PARAM_LST) extends uvm_sequence#(apb_uvc_item#(`APB_UVC_PARAMS));

    typedef bit [ADDR_WIDTH-1:0]        paddr_t;
    typedef bit [2:0]                   pprot_t;
    typedef bit [DATA_WIDTH-1:0]        pwdata_t;
    typedef bit [DATA_WIDTH-1:0]        prdata_t;
    typedef bit [STRB_WIDTH-1:0]        pstrb_t;
    typedef bit [USER_REQ_WIDTH-1:0]    pauser_t;
    typedef bit [USER_DATA_WIDTH-1:0]   pwuser_t;
    typedef bit [USER_DATA_WIDTH-1:0]   pruser_t;
    typedef bit [USER_RESP_WIDTH-1:0]   pbuser_t;

    /* SEQUENCE FIELDS */
    rand paddr_t    paddr;
    rand pprot_t    pprot;
    rand bit        pnse;
    rand bit        psel;
    rand bit        pwrite;
    rand pwdata_t   pwdata;
    rand pstrb_t    pstrb;
    rand prdata_t   prdata;
    rand bit        pslverr;
    rand bit        pwakeup;
    rand pauser_t   pauser;
    rand pwuser_t   pwuser;
    rand pruser_t   pruser;
    rand pbuser_t   pbuser;

    rand dly_typ_e  req_dly_typ;
    rand int        req_dly;
    rand dly_typ_e  rsp_dly_typ;
    rand int        rsp_dly;

    /* SEQUENCE CONSTRAINTS */
    constraint c_req_dly   {
        `DELAY_RANGE_CONSTRAINT(req_dly, req_dly_typ)
        soft req_dly <= 20; req_dly >= 0;
    }

    constraint c_rsp_dly   {
        `DELAY_RANGE_CONSTRAINT(rsp_dly, rsp_dly_typ)
        soft rsp_dly <= 20; rsp_dly >= 0;
    }

    /* SEQUENCE ITEMS */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(apb_uvc_seq_base#(`APB_UVC_PARAMS))
        `uvm_field_int (           paddr,       UVM_DEFAULT)
        `uvm_field_int (           pprot,       UVM_DEFAULT)
        `uvm_field_int (           pnse,        UVM_DEFAULT)
        `uvm_field_int (           psel,        UVM_DEFAULT)
        `uvm_field_int (           pwrite,      UVM_DEFAULT)
        `uvm_field_int (           pwdata,      UVM_DEFAULT)
        `uvm_field_int (           pstrb,       UVM_DEFAULT)
        `uvm_field_int (           prdata,      UVM_DEFAULT)
        `uvm_field_int (           pslverr,     UVM_DEFAULT)
        `uvm_field_int (           pwakeup,     UVM_DEFAULT)
        `uvm_field_int (           pauser,      UVM_DEFAULT)
        `uvm_field_int (           pwuser,      UVM_DEFAULT)
        `uvm_field_int (           pruser,      UVM_DEFAULT)
        `uvm_field_int (           pbuser,      UVM_DEFAULT)
        `uvm_field_enum(dly_typ_e, req_dly_typ, UVM_DEFAULT)
        `uvm_field_int (           req_dly,     UVM_DEFAULT)
        `uvm_field_enum(dly_typ_e, rsp_dly_typ, UVM_DEFAULT)
        `uvm_field_int (           rsp_dly,     UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(apb_uvc_sequencer#(`APB_UVC_PARAMS))

    /* SEQUENCE BODY TASK */
    extern virtual task body();

endclass : apb_uvc_seq_base

task apb_uvc_seq_base::body();

    `uvm_do_with(
        m_req,
        {
            paddr       == local::paddr;
            pprot       == local::pprot;
            pnse        == local::pnse;
            psel        == local::psel;
            pwrite      == local::pwrite;
            pwdata      == local::pwdata;
            pstrb       == local::pstrb;
            prdata      == local::prdata;
            pslverr     == local::pslverr;
            pwakeup     == local::pwakeup;
            pauser      == local::pauser;
            pwuser      == local::pwuser;
            pruser      == local::pruser;
            pbuser      == local::pbuser;
            req_dly_typ == local::req_dly_typ;
            req_dly     == local::req_dly;
            rsp_dly_typ == local::rsp_dly_typ;
            rsp_dly     == local::rsp_dly;
        }
    )

endtask : body

`endif // APB_UVC_SEQ_BASE_SV
