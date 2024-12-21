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
    parameter  int unsigned         XLEN                    = 32,
    parameter  int unsigned         FLEN                    = 32,
    parameter  bit                  RVA                     = 1'b0,
    parameter  bit                  RVC                     = 1'b0,
    parameter  bit                  RVD                     = 1'b0,
    parameter  bit                  RVE                     = 1'b0,
    parameter  bit                  RVF                     = 1'b0,
    parameter  bit                  RVI                     = 1'b1,
    parameter  bit                  RVM                     = 1'b0,
    parameter  bit                  RVS                     = 1'b0,
    parameter  bit                  RVU                     = 1'b0,
    parameter  bit                  ZIFENCEI                = 1'b0,
    parameter  bit                  ZICSR                   = 1'b0,
    parameter  bit                  ZICNTR                  = 1'b0,
    parameter  bit                  ZICOND                  = 1'b0,

    /* CORE PARAMETERS */
    parameter  bit [XLEN-1:0]       PC_RST_VAL              = 'h0010_0000,

    parameter  bit [XLEN-1:0]       VENDOR_ID               = 'h0,
    parameter  bit [XLEN-1:0]       ARCH_ID                 = 'h0,
    parameter  bit [XLEN-1:0]       IMP_ID                  = 'h0,
    parameter  bit [XLEN-1:0]       HART_ID                 = 'h0,

    parameter  bit                  ROB_ENA                 = 1'b0,  // enable reorder buffer
    parameter  bit                  MMU_ENA                 = 1'b0,  // enable memory management unit
    parameter  bit                  PMP_ENA                 = 1'b0,  // enable physical memory protection

    parameter  int unsigned         EXU_CNT                 = 2,
    parameter  exu_type_e           EXU_TYPE [0:EXU_CNT-1]  = {EXU_IB, LSU},

    /* AHB INTERFACE PARAMETERS */
    parameter  int unsigned         ADDR_WIDTH              = XLEN,
    parameter  int unsigned         DATA_WIDTH              = XLEN,
    parameter  int unsigned         HBURST_WIDTH            = 0,
    parameter  int unsigned         HPROT_WIDTH             = 4,
    parameter  int unsigned         HMASTER_WIDTH           = 1,
    parameter  int unsigned         USER_REQ_WIDTH          = 0,
    parameter  int unsigned         USER_DATA_WIDTH         = 0,
    parameter  int unsigned         USER_RESP_WIDTH         = 0,
    localparam int unsigned         STRB_WIDTH              = DATA_WIDTH/8

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
    rv_sbuf_if #(XLEN, FLEN) idu_sbuf_if [0:EXU_CNT-1] ();
    rv_sbuf_if #(XLEN, FLEN) exu_sbuf_if [0:EXU_CNT-1] ();
    rv_sbuf_if #(XLEN, FLEN) wbu_sbuf_if ();

    rv_rwb_if #(
        .ADDR_WIDTH(5       ),
        .DATA_WIDTH(XLEN    )
    ) rfi_if ();

    rv_rwb_if #(
        .ADDR_WIDTH(5       ),
        .DATA_WIDTH(FLEN    )
    ) rff_if ();

    // control transfer signals
    logic [XLEN-1:0]            ct_target;
    logic                       ct_trans;

    // pipeline flush signals
    logic                       ifu_flush;
    logic                       ipu_flush;
    logic                       idu_flush;
    logic                       exu_flush;

    /*
     * INSTRUCTION FETCH UNIT
     */

    rv0_ifu #(`RV0_CORE_PARAMS)
    u_ifu (
        .ifu_flush_i        (ifu_flush          ),
        .ct_target_i        (ct_target          ),
        .ct_trans_i         (ct_trans           ),
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
        .*
    );

    /*
     * EXECUTION UNITS
     */

    for(genvar i = 0; i < EXU_CNT; ++i) begin : exu_genblk

        case(EXU_TYPE[i])

            EXU_I: begin : exu_i_genblk
                rv0_exu_i #(`RV0_CORE_PARAMS)
                u_exu_i (
                    .exu_flush_i    (exu_flush      ),
                    .idu_sbuf_if    (idu_sbuf_if[i] ),
                    .exu_sbuf_if    (exu_sbuf_if[i] ),
                    .*
                );
            end // exu_i_genblk

            EXU_B: begin : exu_b_genblk
                rv0_exu_b #(`RV0_CORE_PARAMS)
                u_exu_b (
                    .exu_flush_i    (exu_flush      ),
                    .idu_sbuf_if    (idu_sbuf_if[i] ),
                    .exu_sbuf_if    (exu_sbuf_if[i] ),
                    .*
                );
            end // exu_b_genblk

            EXU_IB: begin : exu_ib_genblk
                rv0_exu_ib #(`RV0_CORE_PARAMS)
                u_exu_ib (
                    .exu_flush_i    (exu_flush      ),
                    .idu_sbuf_if    (idu_sbuf_if[i] ),
                    .exu_sbuf_if    (exu_sbuf_if[i] ),
                    .*
                );
            end // exu_ib_genblk

            EXU_M: begin : exu_m_genblk
                //rv0_exu_m #(`RV0_CORE_PARAMS)
                //u_exu_m (
                //    .idu_sbuf_if    (idu_sbuf_if[i] ),
                //    .exu_sbuf_if    (exu_sbuf_if[i] ),
                //    .*
                //);
            end // exu_m_genblk

            EXU_F: begin : exu_f_genblk
                //rv0_exu_f #(`RV0_CORE_PARAMS)
                //u_exu_f (
                //    .idu_sbuf_if    (idu_sbuf_if[i] ),
                //    .exu_sbuf_if    (exu_sbuf_if[i] ),
                //    .*
                //);
            end // exu_f_genblk

            LSU: begin : lsu_genblk
                rv0_lsu #(`RV0_CORE_PARAMS)
                u_lsu (
                    .exu_flush_i    (exu_flush      ),
                    .idu_sbuf_if    (idu_sbuf_if[i] ),
                    .exu_sbuf_if    (exu_sbuf_if[i] ),
                    .*
                );
            end // lsu_genblk

            CSU: begin
                //rv0_csu #(`RV0_CORE_PARAMS)
                //u_csu (
                //);
            end

        endcase

    end // exu_genblk

    /*
     * INSTRUCTION WRITE-BACK UNIT
     */

    rv0_wbu #(`RV0_CORE_PARAMS)
    u_wbu (
        .ct_trans_o     (ct_trans   ),
        .ct_target_o    (ct_target  ),
        .*
    );

    /*
     * FRONT-END FLUSH LOGIC
     */

    assign ifu_flush = ct_trans == 1'b1;
    assign ipu_flush = ct_trans == 1'b1;
    assign idu_flush = ct_trans == 1'b1;
    assign exu_flush = ct_trans == 1'b1;

endmodule : rv0_core
