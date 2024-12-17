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
// Name: ahb_uvc_if.sv
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

`ifndef AHB_UVC_IF_SV
`define AHB_UVC_IF_SV

interface ahb_uvc_if #(`AHB_UVC_PARAM_LST) (
    input logic     hclk,
    input logic     hrst_n
);

    /* INTERFACE SIGNALS */
    logic [ADDR_WIDTH-1:0]      haddr;
    logic [HBURST_WIDTH-1:0]    hburst;
    logic                       hmastlock;
    logic [HPROT_WIDTH-1:0]     hprot;
    logic [2:0]                 hsize;
    logic                       hnonsec;
    logic                       hexcl;
    logic [HMASTER_WIDTH-1:0]   hmaster;
    logic [1:0]                 htrans;
    logic [DATA_WIDTH-1:0]      hwdata;
    logic [STRB_WIDTH-1:0]      hwstrb;
    logic                       hwrite;
    logic                       hsel;
    logic [DATA_WIDTH-1:0]      hrdata;
    logic                       hreadyout;
    logic                       hresp;
    logic                       hexokay;
    logic [USER_REQ_WIDTH-1:0]  hauser;
    logic [USER_DATA_WIDTH-1:0] hwuser;
    logic [USER_DATA_WIDTH-1:0] hruser;
    logic [USER_RESP_WIDTH-1:0] hbuser;

    /* INTERFACE MODPORTS */
    modport requester (
        output  haddr,
        output  hburst,
        output  hmastlock,
        output  hprot,
        output  hsize,
        output  hnonsec,
        output  hexcl,
        output  hmaster,
        output  htrans,
        output  hwdata,
        output  hwstrb,
        output  hwrite,
        output  hsel,
        input   hrdata,
        input   hreadyout,
        input   hresp,
        input   hexokay,
        output  hauser,
        output  hwuser,
        input   hruser,
        input   hbuser
    );

    modport completer (
        input   haddr,
        input   hburst,
        input   hmastlock,
        input   hprot,
        input   hsize,
        input   hnonsec,
        input   hexcl,
        input   hmaster,
        input   htrans,
        input   hwdata,
        input   hwstrb,
        input   hwrite,
        input   hsel,
        output  hrdata,
        output  hreadyout,
        output  hresp,
        output  hexokay,
        input   hauser,
        input   hwuser,
        output  hruser,
        output  hbuser
    );

    /* INTERFACE SVA */

endinterface : ahb_uvc_if

`endif // AHB_UVC_IF_SV
