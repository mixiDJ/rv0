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
// Name: ahb_uvc_item.sv
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

`ifndef AHB_UVC_ITEM_SV
`define AHB_UVC_ITEM_SV

class ahb_uvc_item #(`AHB_UVC_PARAM_LST) extends uvm_sequence_item;

    typedef bit [ADDR_WIDTH-1:0]        haddr_t;
    typedef bit [HBURST_WIDTH-1:0]      hburst_t;
    typedef bit [HPROT_WIDTH-1:0]       hprot_t;
    typedef bit [2:0]                   hsize_t;
    typedef bit [HMASTER_WIDTH-1:0]     hmaster_t;
    typedef bit [1:0]                   htrans_t;
    typedef bit [DATA_WIDTH-1:0]        hwdata_t;
    typedef bit [STRB_WIDTH-1:0]        hwstrb_t;
    typedef bit [DATA_WIDTH-1:0]        hrdata_t;
    typedef bit [USER_REQ_WIDTH-1:0]    hauser_t;
    typedef bit [USER_DATA_WIDTH-1:0]   hwuser_t;
    typedef bit [USER_DATA_WIDTH-1:0]   hruser_t;
    typedef bit [USER_RESP_WIDTH-1:0]   hbuser_t;

    /* ITEM FIELDS */
    rand haddr_t    haddr;
    rand hburst_t   hburst;
    rand bit        hmastlock;
    rand hprot_t    hprot;
    rand hsize_t    hsize;
    rand bit        hnonsec;
    rand bit        hexcl;
    rand hmaster_t  hmaster;
    rand htrans_t   htrans;
    rand hwdata_t   hwdata;
    rand hwstrb_t   hwstrb;
    rand bit        hwrite;
    rand bit        hsel;
    rand hrdata_t   hrdata;
    rand bit        hresp;
    rand bit        hexokay;
    rand hauser_t   hauser;
    rand hwuser_t   hwuser;
    rand hruser_t   hruser;
    rand hbuser_t   hbuser;

    rand dly_typ_e  req_dly_typ;
    rand int        req_dly;
    rand dly_typ_e  rsp_dly_typ;
    rand int        rsp_dly;

    /* ITEM CONSTRAINTS */
    constraint c_hsel      { soft hsel      == 1'b1;                    }
    constraint c_hresp     { soft hresp     == HRESP_OKAY;              }
    constraint c_hexokay   { soft hexokay   == 1'b1;                    }

    constraint c_hwstrb    {
        solve hwrite before hwstrb;
        hwrite == 1'b0 -> soft hwstrb == {STRB_WIDTH{1'b0}};
    }

    constraint c_req_dly   {
        `DELAY_RANGE_CONSTRAINT(req_dly, req_dly_typ)
        soft req_dly <= 20; req_dly >= 0;
    }

    constraint c_rsp_dly   {
        `DELAY_RANGE_CONSTRAINT(rsp_dly, rsp_dly_typ)
        soft rsp_dly <= 20; rsp_dly >= 0;
    }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(ahb_uvc_item#(`AHB_UVC_PARAMS))
        `uvm_field_int (           haddr,       UVM_DEFAULT)
        `uvm_field_int (           hburst,      UVM_DEFAULT)
        `uvm_field_int (           hmastlock,   UVM_DEFAULT)
        `uvm_field_int (           hprot,       UVM_DEFAULT)
        `uvm_field_int (           hsize,       UVM_DEFAULT)
        `uvm_field_int (           hnonsec,     UVM_DEFAULT)
        `uvm_field_int (           hexcl,       UVM_DEFAULT)
        `uvm_field_int (           hmaster,     UVM_DEFAULT)
        `uvm_field_int (           htrans,      UVM_DEFAULT)
        `uvm_field_int (           hwdata,      UVM_DEFAULT)
        `uvm_field_int (           hwstrb,      UVM_DEFAULT)
        `uvm_field_int (           hwrite,      UVM_DEFAULT)
        `uvm_field_int (           hsel,        UVM_DEFAULT)
        `uvm_field_int (           hrdata,      UVM_DEFAULT)
        `uvm_field_int (           hresp,       UVM_DEFAULT)
        `uvm_field_int (           hexokay,     UVM_DEFAULT)
        `uvm_field_int (           hauser,      UVM_DEFAULT)
        `uvm_field_int (           hwuser,      UVM_DEFAULT)
        `uvm_field_int (           hruser,      UVM_DEFAULT)
        `uvm_field_int (           hbuser,      UVM_DEFAULT)
        `uvm_field_enum(dly_typ_e, req_dly_typ, UVM_DEFAULT)
        `uvm_field_int (           req_dly,     UVM_DEFAULT)
        `uvm_field_enum(dly_typ_e, req_dly_typ, UVM_DEFAULT)
        `uvm_field_int (           rsp_dly,     UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : ahb_uvc_item

`endif // AHB_UVC_ITEM_SV
