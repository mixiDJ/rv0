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
// Name: rv0_wbu.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc: Write-back unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_wbu #(`RV0_CORE_PARAM_LST) (

    input  logic                        clk_i,
    input  logic                        rst_ni,

    rv_sbuf_if.sink                     exu_sbuf_if,
    rv_sbuf_if.sink                     lsu_sbuf_if,

    output logic [4:0]                  rfi_waddr_o,
    output logic [XLEN-1:0]             rfi_wdata_o,
    output logic                        rfi_we_o,

    output logic [4:0]                  rff_waddr_o,
    output logic [XLEN-1:0]             rff_wdata_o,
    output logic                        rff_we_o

);

    /*
     * WRITE-BACK ARBITRATION LOGIC
     */

    typedef enum logic [1:0] {
        ARBT_EXU,
        ARBT_LSU
    } wbu_arbt_e;

    wbu_arbt_e  wbu_arbt;

    always_comb begin
        wbu_arbt = ARBT_EXU;
        if(lsu_sbuf_if.rdy == 1'b1) begin
            wbu_arbt = ARBT_LSU;
        end
    end

    always_comb begin
        rfi_waddr_o = 5'h0;
        rfi_wdata_o = {XLEN{1'b0}};
        rff_waddr_o = 5'h0;
        rff_wdata_o = {FLEN{1'b0}};

        case(wbu_arbt)
            ARBT_EXU: begin
                rfi_waddr_o = exu_sbuf_if.rd;
                rfi_wdata_o = exu_sbuf_if.idata1;
            end
            ARBT_LSU: begin
                rfi_waddr_o = lsu_sbuf_if.rd;
                rfi_wdata_o = lsu_sbuf_if.idata1;
            end
        endcase

    end

    assign exu_sbuf_if.ack = 1'b1; //wbu_arbt == ARBT_EXU;
    assign lsu_sbuf_if.ack = 1'b1; //wbu_arbt == ARBT_LSU;

    /*
     * INSTRUCTION RETIRE ADDRESS LOGIC
     */

    logic [XLEN-1:0] iret_addr_d;
    logic [XLEN-1:0] iret_addr_q;
    logic [31:0]     iret_insn;

    always_comb begin
        case(wbu_arbt)
            ARBT_EXU: begin
                iret_addr_d = exu_sbuf_if.addr;
                iret_insn   = exu_sbuf_if.insn;
            end
            ARBT_LSU: begin
                iret_addr_d = lsu_sbuf_if.addr;
                iret_insn   = lsu_sbuf_if.insn;
            end
        endcase
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) iret_addr_q <= {XLEN{1'b1}};
        else iret_addr_q <= iret_addr_d;
    end

    /*
     * REGISTER WRITE-BACK DATA LOGIC
     */

    always_comb begin
        rfi_we_o = 1'b0;
        rff_we_o = 1'b0;

        case(iret_insn[6:0])
            LUI:        rfi_we_o = 1'b1;
            AUIPC:      rfi_we_o = 1'b1;
            JAL:        rfi_we_o = 1'b1;
            JALR:       rfi_we_o = 1'b1;
            BRANCH:     rfi_we_o = 1'b0;
            LOAD:       rfi_we_o = 1'b1;
            STORE:      rfi_we_o = 1'b0;
            OP_IMM:     rfi_we_o = 1'b1;
            OP:         rfi_we_o = 1'b1;
            OP_IMM_32:  rfi_we_o = 1'b1;
            OP_32:      rfi_we_o = 1'b1;
        endcase

        if(iret_addr_d == iret_addr_q) begin
            rfi_we_o = 1'b0;
            rff_we_o = 1'b0;
        end

        if(rfi_waddr_o == 5'h0) rfi_we_o = 1'b0;
        if(rff_waddr_o == 5'h0) rff_we_o = 1'b0;
    end

endmodule : rv0_wbu
