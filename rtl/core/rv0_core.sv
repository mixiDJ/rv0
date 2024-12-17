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
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_core.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_core #(

    /* ISA PARAMETERS */
    parameter  int unsigned         XLEN            = 32,
    parameter  int unsigned         FLEN            = 32,
    parameter  bit                  RVA             = 1'b0,
    parameter  bit                  RVC             = 1'b0,
    parameter  bit                  RVD             = 1'b0,
    parameter  bit                  RVE             = 1'b0,
    parameter  bit                  RVF             = 1'b0,
    parameter  bit                  RVI             = 1'b1,
    parameter  bit                  RVM             = 1'b0,
    parameter  bit                  RVS             = 1'b0,
    parameter  bit                  RVU             = 1'b0,
    parameter  bit                  ZIFENCEI        = 1'b0,
    parameter  bit                  ZICSR           = 1'b0,
    parameter  bit                  ZICNTR          = 1'b0,
    parameter  bit                  ZICOND          = 1'b0,

    /* CORE PARAMETERS */
    parameter  bit [XLEN-1:0]       PC_RST_VAL      = 'h0010_0000,

    parameter  bit [XLEN-1:0]       VENDOR_ID       = 'h0,
    parameter  bit [XLEN-1:0]       ARCH_ID         = 'h0,
    parameter  bit [XLEN-1:0]       IMP_ID          = 'h0,
    parameter  bit [XLEN-1:0]       HART_ID         = 'h0,

    parameter  bit                  ROB_ENA         = 1'b0,  // enable reorder buffer
    parameter  bit                  MMU_ENA         = 1'b0,  // enable memory management unit
    parameter  bit                  PMP_ENA         = 1'b0,  // enable physical memory protection

    /* AHB INTERFACE PARAMETERS */
    parameter  int unsigned         ADDR_WIDTH      = 32,
    parameter  int unsigned         DATA_WIDTH      = 32,
    parameter  int unsigned         HBURST_WIDTH    = 0,
    parameter  int unsigned         HPROT_WIDTH     = 4,
    parameter  int unsigned         HMASTER_WIDTH   = 1,
    parameter  int unsigned         USER_REQ_WIDTH  = 0,
    parameter  int unsigned         USER_DATA_WIDTH = 0,
    parameter  int unsigned         USER_RESP_WIDTH = 0,
    localparam int unsigned         STRB_WIDTH      = DATA_WIDTH/8

) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    // instruction memory interface
    ahb_if.requester                imem_if,
    // data memory interface
    ahb_if.requester                dmem_if

);

    rv_sbuf_if #(XLEN, FLEN) ifu_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) ipu_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) idu_ei_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) idu_em_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) idu_ef_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) idu_ma_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) exu_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) lsu_sbuf_if ();
    rv_sbuf_if #(XLEN, FLEN) wbu_sbuf_if ();

    logic [4:0]                 rfi_waddr;
    logic [XLEN-1:0]            rfi_wdata;
    logic                       rfi_we;

    logic [4:0]                 rff_waddr;
    logic [FLEN-1:0]            rff_wdata;
    logic                       rff_we;

    logic [XLEN-1:0]            ifu_fc_target;
    logic                       ifu_fc_trans;
    logic [XLEN-1:0]            ifu_trap_target;
    logic                       ifu_trap_trans;

    logic                       ifu_flush;
    logic                       ipu_flush;
    logic                       idu_flush;

    /*
     * INSTRUCTION FETCH UNIT
     */

    rv0_ifu #(`RV0_CORE_PARAMS)
    u_ifu (
        .ifu_flush_i        (ifu_flush          ),
        .ifu_fc_target_i    (ifu_fc_target      ),
        .ifu_fc_trans_i     (ifu_fc_trans       ),
        .*
    );

    /*
     * INSTRUCTION PRE-DECODE UNIT
     */

    rv0_ipu #(`RV0_CORE_PARAMS)
    u_ipu (
        .ipu_flush_i        (ipu_flush          ),
        .*
    );

    /*
     * INSTRUCTION DECODE UNIT
     */

    rv0_idu #(`RV0_CORE_PARAMS)
    u_idu (
        .idu_flush_i        (idu_flush          ),

        .rfi_waddr_i        (rfi_waddr          ),
        .rfi_wdata_i        (rfi_wdata          ),
        .rfi_we_i           (rfi_we             ),

        .rff_waddr_i        (rff_waddr          ),
        .rff_wdata_i        (rff_wdata          ),
        .rff_we_i           (rff_we             ),

        .*
    );

    /*
     * INSTRUCTION EXECUTE UNIT
     */

    rv0_exu #(`RV0_CORE_PARAMS)
    u_exu (
        .ifu_fc_target_o    (ifu_fc_target      ),
        .ifu_fc_trans_o     (ifu_fc_trans       ),
        .*
    );

    /*
     * INSTRUCTION WRITE-BACK UNIT
     */

    rv0_wbu #(`RV0_CORE_PARAMS)
    u_wbu (
        .rfi_waddr_o        (rfi_waddr          ),
        .rfi_wdata_o        (rfi_wdata          ),
        .rfi_we_o           (rfi_we             ),
        .*
    );

    /*
     * LOAD STORE UNIT
     */

    rv0_lsu #(`RV0_CORE_PARAMS)
    u_lsu (.*);

    /*
     * CONTROL & STATUS REGISTERS
     */

    rv0_csr #(`RV0_CORE_PARAMS)
    u_csr (.*);

    /*
     * FRONT-END FLUSH LOGIC
     */

    assign ifu_flush = ifu_fc_trans == 1'b1;
    assign ipu_flush = ifu_fc_trans == 1'b1;
    assign idu_flush = ifu_fc_trans == 1'b1;

endmodule : rv0_core
