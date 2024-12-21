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
// Name: rv0_alu_i.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_alu_i #(`RV0_CORE_PARAM_LST) (

    input  logic [31:0]         alu_insn_i,
    input  logic [XLEN-1:0]     alu_addr_i,

    input  logic [XLEN-1:0]     alu_rdata1_i,
    input  logic [XLEN-1:0]     alu_rdata2_i,

    output logic [XLEN-1:0]     alu_wdata_o

);

    localparam int unsigned SHAMT_WIDTH_32 = 5;
    localparam int unsigned SHAMT_WIDTH_64 = 6;
    localparam int unsigned SHAMT_WIDTH    = XLEN == 64 ? SHAMT_WIDTH_64 : SHAMT_WIDTH_32;

    rv_opcode_e             opcode;
    logic [2:0]             funct3;
    logic [6:0]             funct7;
    logic [SHAMT_WIDTH-1:0] shamt;
    logic                   mod;
    logic [XLEN-1:0]        alu_res;

    assign opcode = rv_opcode_e'(alu_insn_i[6:0]);
    assign funct3 = alu_insn_i[14:12];
    assign funct7 = alu_insn_i[31:25];
    assign mod    = alu_insn_i[30];

    logic unsigned [XLEN-1:0]   rdata1;
    logic unsigned [XLEN-1:0]   rdata2;
    logic signed   [XLEN-1:0]   srdata1;
    logic signed   [XLEN-1:0]   srdata2;
    logic unsigned [31:0]       rdata1_w;
    logic unsigned [31:0]       rdata2_w;
    logic signed   [31:0]       srdata1_w;
    logic signed   [31:0]       srdata2_w;

    if(XLEN == 64) begin : rdata_xlen64_genblk
    end // rdata_xlen64_genblk

    if(XLEN == 32) begin : rdata_xlen32_genblk

        assign rdata1  = alu_rdata1_i;
        assign rdata2  = alu_rdata2_i;
        assign srdata1 = alu_rdata1_i;
        assign srdata2 = alu_rdata2_i;

    end // rdata_xlen32_genblk

    if(XLEN == 64) begin : shamt_xlen64_genblk
        // TODO
    end // shamt_xlen64_genblk

    if(XLEN == 32) begin : shamt_xlen32_genblk
        assign shamt = rdata2[SHAMT_WIDTH_32-1:0];
    end // shamt_xlen32_genblk

    always_comb begin
        alu_res = {XLEN{1'b0}};

        case(opcode)
            LUI:   alu_res = {{XLEN-32{alu_insn_i[31]}}, alu_insn_i[31:12], 12'h0};
            AUIPC: alu_res = {{XLEN-32{alu_insn_i[31]}}, alu_insn_i[31:12], 12'h0} + alu_addr_i;
            OP_IMM: begin
                case(funct3)
                    ADDI:  alu_res = rdata1  +  rdata2;
                    SLLI:  alu_res = rdata1  << shamt;
                    SLTI:  alu_res = srdata1 <  srdata2;
                    SLTIU: alu_res = rdata1  <  rdata2;
                    XORI:  alu_res = rdata1  ^  rdata2;
                    SRLI: begin
                        if(mod == 1'b1) alu_res = srdata1 >>> shamt;
                        else alu_res = rdata1 >> shamt;
                    end
                    ORI:   alu_res = rdata1 | rdata2;
                    ANDI:  alu_res = rdata1 & rdata2;
                endcase
            end
            OP: begin
                case(funct3)
                    ADD:  alu_res = mod ? rdata1 - rdata2 : rdata1 + rdata2;
                    SLL:  alu_res = rdata1 << shamt;
                    SLT:  alu_res = srdata1 < srdata2;
                    SLTU: alu_res = rdata1 < rdata2;
                    XOR:  alu_res = rdata1 ^ rdata2;
                    SRL: begin
                        if(mod) alu_res = srdata1 >>> shamt;
                        else alu_res = rdata1 >> shamt;
                    end
                    OR:   alu_res = rdata1 | rdata2;
                    AND:  alu_res = rdata1 & rdata2;
                endcase
            end
            default: alu_res = rdata1 + rdata2;
        endcase
    end

    if(XLEN == 64) begin : alu_wdata_xlen64_genblk

        always_comb begin
            alu_wdata_o = alu_res;
        end

    end // alu_wdata_xlen64_genblk

    if(XLEN == 32) begin : alu_wdata_xlen32_genblk
        assign alu_wdata_o = alu_res;
    end // alu_wdata_xlen32_genblk

endmodule : rv0_alu_i
