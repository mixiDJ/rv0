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
// Name: rv0_csr.sv
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

module rv0_csr #(`RV0_CORE_PARAM_LST) (

    input  logic        clk_i,
    input  logic        rst_ni

    //rv_csr_if.sink      csr_if

);

    typedef enum bit [11:0] {

        CSR_ADDR_FFLAGS         = 12'h001,
        CSR_ADDR_FRM            = 12'h002,
        CSR_ADDR_FCSR           = 12'h003,

        CSR_ADDR_CYCLE          = 12'hc00,
        CSR_ADDR_TIME           = 12'hc01,
        CSR_ADDR_INSTRET        = 12'hc02,
        CSR_ADDR_HPMCOUNTER3    = 12'hc03,
        CSR_ADDR_CYCLEH         = 12'hc1f,
        CSR_ADDR_TIMEH          = 12'hc80,
        CSR_ADDR_INSTRETH       = 12'hc81,
        CSR_ADDR_HMPCOUNTER3H   = 12'hc83,

        CSR_ADDR_MVENDORID      = 12'hf11,
        CSR_ADDR_MARCHID        = 12'hf12,
        CSR_ADDR_MIMPID         = 12'hf13,
        CSR_ADDR_MHARTID        = 12'hf14,
        CSR_ADDR_MCONFIGPTR     = 12'hf15,

        CSR_ADDR_MSTATUS        = 12'h300,
        CSR_ADDR_MISA           = 12'h301,
        CSR_ADDR_MEDELEG        = 12'h302,
        CSR_ADDR_MIDELEG        = 12'h303,
        CSR_ADDR_MIE            = 12'h304,
        CSR_ADDR_MTVEC          = 12'h305,
        CSR_ADDR_MCOUNTEREN     = 12'h306,
        CSR_ADDR_MSTATUSH       = 12'h310,
        CSR_ADDR_MEDELEGH       = 12'h312,

        CSR_ADDR_MSCRATCH       = 12'h340,
        CSR_ADDR_MEPC           = 12'h341,
        CSR_ADDR_MCAUSE         = 12'h342,
        CSR_ADDR_MTVAL          = 12'h343,
        CSR_ADDR_MIP            = 12'h344,
        CSR_ADDR_MTINST         = 12'h34a,
        CSR_ADDR_MTVAL2         = 12'h34b,

        CSR_ADDR_MENVCFG        = 12'h30a,
        CSR_ADDR_MENVCFGH       = 12'h31a,
        CSR_ADDR_MSECCFG        = 12'h737,
        CSR_ADDR_MSECCFGH       = 12'h757,

        CSR_ADDR_MNSCRATCH      = 12'h740,
        CSR_ADDR_MNEPC          = 12'h741,
        CSR_ADDR_MNCAUSE        = 12'h742,
        CSR_ADDR_MNSTATUS       = 12'h744,

        CSR_ADDR_MCYCLE         = 12'hb00,
        CSR_ADDR_MINSTRET       = 12'hb02,

        CSR_ADDR_MCOUNTINHIBIT  = 12'h320,

        CSR_ADDR_TSELECT        = 12'h7a0,
        CSR_ADDR_TDATA1         = 12'h7a1,
        CSR_ADDR_TDATA2         = 12'h7a2,
        CSR_ADDR_TDATA3         = 12'h7a3,
        CSR_ADDR_MCONTEXT       = 12'h7a8,

        CSR_ADDR_DCSR           = 12'h7b0,
        CSR_ADDR_DPC            = 12'h7b1,
        CSR_ADDR_DSCRATCH0      = 12'h7b2,
        CSR_ADDR_DSCRATCH1      = 12'h7b3
    } csr_addr_e;


if(ZICSR == 1'b1) begin : zicsr_genblk

    /*
     * MISA
     */

    logic [XLEN-1:0] csr_misa_q;
    logic [XLEN-1:0] csr_misa_d;
    logic [XLEN-1:0] csr_misa;

    always_comb begin
        csr_misa_d = csr_misa_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
    end

    assign csr_misa = csr_misa_q;

    /*
     * MVENDORID
     */

    logic [31:0] csr_mvendorid;
    //assign csr_mvendorid =

    /*
     * MARCHID
     */

    logic [XLEN-1:0] csr_marchid;
    //assign csr_marchid =

    /*
     * MIMPID
     */

    logic [XLEN-1:0] csr_mimpid;
    //assign csr_mimpid =

    /*
     * MHARTID
     */

    logic [XLEN-1:0] csr_mhartid;
    assign csr_mhartid = HART_ID;

    /*
     * MSTATUS
     */

    logic [XLEN-1:0] csr_mstatus_q;
    logic [XLEN-1:0] csr_mstatus_d;

    if(XLEN == 64) begin : csr_mstatus_xlen64_genblk

        always_comb begin
            csr_mstatus_d = csr_mstatus_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end // csr_mstatus_xlen64_genblk
    else begin : csr_mstatus_xlen32_genblk

        always_comb begin
            csr_mstatus_d = csr_mstatus_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end // csr_mstatus_xlen32_genblk

    /*
     * MSTATUSH
     */

    logic [31:0] csr_mstatush_q;
    logic [31:0] csr_mstatush_d;

    if(XLEN == 32) begin : csr_mstatush_genblk

        always_comb begin
            csr_mstatush_d = csr_mstatush_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end // csr_mstatush_genblk

    logic [63:0] csr_mstatus;
    if(XLEN == 64) assign csr_mstatus = csr_mstatus_q;
    if(XLEN == 32) assign csr_mstatus = {csr_mstatush_q, csr_mstatus_q};

    /*
     * MTVEC
     */

    logic [XLEN-1:0] csr_mtvec_q;
    logic [XLEN-1:0] csr_mtvec_d;
    logic [XLEN-1:0] csr_mtvec;

    always_comb begin
        csr_mtvec_d = csr_mtvec_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
    end

    assign csr_mtvec = csr_mtvec_q;

    /*
     * MEDELEG
     */

    logic [XLEN-1:0] csr_medeleg_q;
    logic [XLEN-1:0] csr_medeleg_d;

    if(XLEN == 64) begin : csr_medeleg_xlen64_genblk

        always_comb begin
            csr_medeleg_d = csr_medeleg_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end // csr_medeleg_xlen64_genblk
    if(XLEN == 32) begin: csr_medeleg_xlen32_genblk

        always_comb begin
            csr_medeleg_d = csr_medeleg_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end // csr_medeleg_xlen32_genblk

    /*
     * MEDELEGH
     */

    logic [XLEN-1:0] csr_medelegh_q;
    logic [XLEN-1:0] csr_medelegh_d;

    if(XLEN == 32) begin : csr_medelegh_xlen32_genblk

        always_comb begin
            csr_medelegh_d = csr_medelegh_q;
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
        end

    end

    logic [63:0] csr_medeleg;
    if(XLEN == 64) assign csr_medeleg = csr_medeleg_q;
    if(XLEN == 32) assign csr_medeleg = {csr_medelegh_q, csr_medeleg_q};

    /*
     * MIDELEG
     */

    logic [XLEN-1:0] csr_mideleg_q;
    logic [XLEN-1:0] csr_mideleg_d;

    always_comb begin
        csr_mideleg_d = csr_mideleg_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
    end

    logic [XLEN-1:0] csr_mideleg;
    assign csr_mideleg = csr_mideleg_q;

    /*
     * MIP
     */

    logic [XLEN-1:0] csr_mip_q;
    logic [XLEN-1:0] csr_mip_d;

    always_comb begin
        csr_mip_d = csr_mip_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
    end

    logic [XLEN-1:0] csr_mip;
    assign csr_mip = csr_mip_q;

    /*
     * MIE
     */

    logic [XLEN-1:0] csr_mie_q;
    logic [XLEN-1:0] csr_mie_d;

    always_comb begin
        csr_mie_d = csr_mie_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
    end

    logic [XLEN-1:0] csr_mie;
    assign csr_mie = csr_mie_q;

    /*
     * SUPERVISOR MODE REGISTERS
     */

    if(RVS == 1'b1) begin : zicsr_rvs_genblk
        // TODO
    end // zicsr_rvs_genblk

    /*
     * USER MODE REGISTERS
     */

    if(RVU == 1'b1) begin : zicsr_rvu_genblk
        // TODO
    end // zicsr_rvu_genblk

    /*
     * CSR READ DATA LOGIC
     */

    logic [XLEN-1:0] csr_rdata;
    logic [11:0] csr_addr;

    always_comb begin
        case(csr_addr)
            CSR_ADDR_MVENDORID:     csr_rdata = csr_mvendorid;
            CSR_ADDR_MARCHID:       csr_rdata = csr_marchid;
            CSR_ADDR_MIMPID:        csr_rdata = csr_mimpid;
            CSR_ADDR_MHARTID:       csr_rdata = csr_mhartid;
            //CSR_ADDR_MCONFIGPTR:    csr_rdata = csr_mconfigptr;
            CSR_ADDR_MSTATUS:       csr_rdata = csr_mstatus_q;
            CSR_ADDR_MISA:          csr_rdata = csr_misa_q;
            CSR_ADDR_MEDELEG:       csr_rdata = csr_medeleg_q;
            CSR_ADDR_MIDELEG:       csr_rdata = csr_mideleg_q;
            CSR_ADDR_MIE:           csr_rdata = csr_mie_q;
            CSR_ADDR_MTVEC:         csr_rdata = csr_mtvec_q;
            //CSR_ADDR_MCOUNTEREN:    csr_rdata = csr_mcounteren_q;
            CSR_ADDR_MSTATUSH:      csr_rdata = csr_mstatush_q;
            CSR_ADDR_MEDELEGH:      csr_rdata = csr_medelegh_q;
        endcase
    end

end // zicsr_genblk
else begin : zicsr_bypass_genblk

end // zicsr_bypass_genblk

endmodule : rv0_csr
