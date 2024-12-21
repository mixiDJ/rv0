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
// Name: rv0_core_ifs.sv
// Auth: Nikola Lukić
// Date: 18.12.2024.
// Desc: Core interface definitions
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

import rv0_core_defs::*;

/*
 * RISC-V PIPELINE SKID BUFFER INTERFACE
 */

interface rv_sbuf_if #(
    parameter int unsigned XLEN = 32,
    parameter int unsigned FLEN = 32
);

    /* INSTRUCTION SIGNALS */
    logic [XLEN-1:0]            insn;
    logic [31:0]                addr;

    rv_opcode_e                 opcode;
    logic [6:0]                 funct7;
    logic [2:0]                 funct3;

    logic [4:0]                 rd;
    logic [4:0]                 rs1;
    logic [4:0]                 rs2;

    /* DATA SIGNALS */
    logic [XLEN-1:0]            idata1;
    logic [XLEN-1:0]            idata2;

    logic [FLEN-1:0]            fdata1;
    logic [FLEN-1:0]            fdata2;

    /* TAGS */
    logic [31:0]                tags;
    //   idx        name    desc
    //     0        bpt     branch predict taken
    //     1        ctt     control transfer taken
    //   3:2        priv    current privilege level
    //     4        eiam    instruction address misaligned
    //     5        eiaf    instruction access fault
    //     6        eii     illegal instruction
    //     7        ebrk    breakpoint
    //     8        elam    load address misaligned
    //     9        elaf    load access fault
    //    10        esam    store address misaligned
    //    11        esaf    store address misaligned
    //    12        eec     environment call

    /* SKID BUFFER SIGNALS */
    logic                       rdy;
    logic                       ack;

    /* INSTRUCTION BREAKOUT ASSIGNMENTS */
    assign opcode = rv_opcode_e'(insn[6:0]);
    assign funct3 = insn[14:12];
    assign funct7 = insn[31:25];
    assign rd     = insn[11:7];
    assign rs1    = insn[19:15];
    assign rs2    = insn[24:20];

    /* MODPORTS */
    modport source (
        output insn,
        output addr,
        output opcode,
        output funct3,
        output funct7,
        output rd,
        output rs1,
        output rs2,
        output idata1,
        output idata2,
        output fdata1,
        output fdata2,
        output tags,
        output rdy,
        input  ack
    );

    modport sink (
        input  insn,
        input  addr,
        output opcode,
        output funct3,
        output funct7,
        output rd,
        output rs1,
        output rs2,
        input  idata1,
        input  idata2,
        input  fdata1,
        input  fdata2,
        input  tags,
        input  rdy,
        output ack
    );

    modport monitor (
        input  insn,
        input  addr,
        input  opcode,
        input  funct3,
        input  funct7,
        input  rd,
        input  rs1,
        input  rs2,
        input  idata1,
        input  idata2,
        input  fdata1,
        input  fdata2,
        input  tags,
        input  rdy,
        input  ack
    );

endinterface : rv_sbuf_if

/*
 * RISC-V REGISTER WRITE-BACK INTERFACE
 */

interface rv_rwb_if #(
    parameter int unsigned ADDR_WIDTH = 5,
    parameter int unsigned DATA_WIDTH = 32
);

    logic [ADDR_WIDTH-1:0]  waddr;
    logic [DATA_WIDTH-1:0]  wdata;
    logic                   we;

    modport source (
        output  waddr,
        output  wdata,
        output  we
    );

    modport sink (
        input   waddr,
        input   wdata,
        input   we
    );

    modport monitor (
        input   waddr,
        input   wdata,
        input   we
    );

endinterface : rv_rwb_if

/*
 * AHB INTERFACE
 */

interface ahb_if #(
    parameter  int unsigned ADDR_WIDTH      = 32,
    parameter  int unsigned DATA_WIDTH      = 32,
    parameter  int unsigned HBURST_WIDTH    = 0,
    parameter  int unsigned HPROT_WIDTH     = 4,
    parameter  int unsigned HMASTER_WIDTH   = 1,
    parameter  int unsigned USER_REQ_WIDTH  = 0,
    parameter  int unsigned USER_DATA_WIDTH = 0,
    parameter  int unsigned USER_RESP_WIDTH = 0,
    localparam int unsigned STRB_WIDTH      = DATA_WIDTH/8
);

    logic [ADDR_WIDTH-1:0]       haddr;
    logic [HBURST_WIDTH-1:0]     hburst;
    logic                        hmastlock;
    logic [HPROT_WIDTH-1:0]      hprot;
    logic [2:0]                  hsize;
    logic                        hnonsec;
    logic                        hexcl;
    logic [HMASTER_WIDTH-1:0]    hmaster;
    logic [1:0]                  htrans;
    logic [DATA_WIDTH-1:0]       hwdata;
    logic [STRB_WIDTH-1:0]       hwstrb;
    logic                        hwrite;
    logic                        hsel;
    logic [DATA_WIDTH-1:0]       hrdata;
    logic                        hreadyout;
    logic                        hresp;
    logic                        hexokay;
    logic [USER_REQ_WIDTH-1:0]   hauser;
    logic [USER_DATA_WIDTH-1:0]  hwuser;
    logic [USER_DATA_WIDTH-1:0]  hruser;
    logic [USER_RESP_WIDTH-1:0]  hbuser;

    modport requester (
        output haddr,
        output hburst,
        output hmastlock,
        output hprot,
        output hsize,
        output hnonsec,
        output hexcl,
        output hmaster,
        output htrans,
        output hwdata,
        output hwstrb,
        output hwrite,
        output hsel,
        input  hrdata,
        input  hreadyout,
        input  hresp,
        input  hexokay,
        output hauser,
        output hwuser,
        input  hruser,
        input  hbuser
    );

    modport completer (
        input  haddr,
        input  hburst,
        input  hmastlock,
        input  hprot,
        input  hsize,
        input  hnonsec,
        input  hexcl,
        input  hmaster,
        input  htrans,
        input  hwdata,
        input  hwstrb,
        input  hwrite,
        input  hsel,
        output hrdata,
        output hreadyout,
        output hresp,
        output hexokay,
        input  hauser,
        input  hwuser,
        output hruser,
        output hbuser
    );

    modport monitor (
        input  haddr,
        input  hburst,
        input  hmastlock,
        input  hprot,
        input  hsize,
        input  hnonsec,
        input  hexcl,
        input  hmaster,
        input  htrans,
        input  hwdata,
        input  hwstrb,
        input  hwrite,
        input  hsel,
        input  hrdata,
        input  hreadyout,
        input  hresp,
        input  hexokay,
        input  hauser,
        input  hwuser,
        input  hruser,
        input  hbuser
    );

endinterface : ahb_if
