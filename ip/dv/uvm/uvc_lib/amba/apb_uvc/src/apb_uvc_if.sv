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
// Name: apb_uvc_if.sv
// Auth: Nikola Lukić
// Date: 16.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_IF_SV
`define APB_UVC_IF_SV

interface apb_uvc_if #(`APB_UVC_PARAM_LST) (
    input logic pclk,
    input logic prst_n
);

    /* INTERFACE SIGNALS */
    logic [ADDR_WIDTH-1:0]          paddr;
    logic [2:0]                     pprot;
    logic                           pnse;
    logic                           psel;
    logic                           penable;
    logic                           pwrite;
    logic [DATA_WIDTH-1:0]          pwdata;
    logic [STRB_WIDTH-1:0]          pstrb;
    logic                           pready;
    logic [DATA_WIDTH-1:0]          prdata;
    logic                           pslverr;
    logic                           pwakeup;
    logic [USER_REQ_WIDTH-1:0]      pauser;
    logic [USER_DATA_WIDTH-1:0]     pwuser;
    logic [USER_DATA_WIDTH-1:0]     pruser;
    logic [USER_RESP_WIDTH-1:0]     pbuser;
    logic [ADDR_CHK_WIDTH-1:0]      paddrchk;
    logic                           pctrlchk;
    logic                           pselchk;
    logic                           penablechk;
    logic [DATA_CHK_WIDTH-1:0]      pwdatachk;
    logic                           pstrbchk;
    logic                           preadychk;
    logic [DATA_CHK_WIDTH-1:0]      prdatachk;
    logic                           pslverrchk;
    logic                           pwakeupchk;
    logic [USER_REQ_CHK_WIDTH-1:0]  pauserchk;
    logic [USER_DATA_CHK_WIDTH-1:0] pwuserchk;
    logic [USER_DATA_CHK_WIDTH-1:0] pruserchk;
    logic [USER_RESP_CHK_WIDTH-1:0] pbuserchk;

    /* INTERFACE MODPORTS */
    modport requester (
        output  paddr,
        output  pprot,
        output  pnse,
        output  psel,
        output  penable,
        output  pwrite,
        output  pwdata,
        output  pstrb,
        input   pready,
        input   prdata,
        input   pslverr,
        output  pwakeup,
        output  pauser,
        output  pwuser,
        input   pruser,
        input   pbuser,
        output  paddrchk,
        output  pctrlchk,
        output  pselchk,
        output  penablechk,
        output  pwdatachk,
        output  pstrbchk,
        input   preadychk,
        input   prdatachk,
        input   pslverrchk,
        output  pwakeupchk,
        output  pauserchk,
        output  pwuserchk,
        input   pruserchk,
        input   pbuserchk
    );

    modport completer (
        input   paddr,
        input   pprot,
        input   pnse,
        input   psel,
        input   penable,
        input   pwrite,
        input   pwdata,
        input   pstrb,
        output  pready,
        output  prdata,
        output  pslverr,
        input   pwakeup,
        input   pauser,
        input   pwuser,
        output  pruser,
        output  pbuser,
        input   paddrchk,
        input   pctrlchk,
        input   pselchk,
        input   penablechk,
        input   pwdatachk,
        input   pstrbchk,
        output  preadychk,
        output  prdatachk,
        output  pslverrchk,
        input   pwakeupchk,
        input   pauserchk,
        input   pwuserchk,
        output  pruserchk,
        output  pbuserchk
    );

    /* INTERFACE SVA */

endinterface : apb_uvc_if

`endif // APB_UVC_IF_SV
