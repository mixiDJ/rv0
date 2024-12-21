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

    input  logic                    clk_i,
    input  logic                    rst_ni,

    // control transfer signals
    output logic [XLEN-1:0]         ct_target_o,
    output logic                    ct_trans_o,

    // reorder buffer interface
    //rv_sbuf_if.sink                 rob_sbuf_if,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                 exu_sbuf_if [0:EXU_CNT-1],
    rv_sbuf_if.source               wbu_sbuf_if,

    // integer register write-back interface
    rv_rwb_if.source                rfi_if,

    // floating-point register write-back interface
    rv_rwb_if.source                rff_if

);

    logic               exu_sbuf_rdy    [0:EXU_CNT-1];
    logic [XLEN-1:0]    exu_sbuf_addr   [0:EXU_CNT-1];
    logic [31:0]        exu_sbuf_insn   [0:EXU_CNT-1];
    logic [XLEN-1:0]    exu_sbuf_idata1 [0:EXU_CNT-1];
    logic [XLEN-1:0]    exu_sbuf_idata2 [0:EXU_CNT-1];
    logic [FLEN-1:0]    exu_sbuf_fdata  [0:EXU_CNT-1];
    logic [TLEN-1:0]    exu_sbuf_tags   [0:EXU_CNT-1];

    for(genvar i = 0; i < EXU_CNT; ++i) begin : exu_sbuf_rdy_genblk
        assign exu_sbuf_rdy[i]    = exu_sbuf_if[i].rdy;
        assign exu_sbuf_addr[i]   = exu_sbuf_if[i].addr;
        assign exu_sbuf_insn[i]   = exu_sbuf_if[i].insn;
        assign exu_sbuf_idata1[i] = exu_sbuf_if[i].idata1;
        assign exu_sbuf_idata2[i] = exu_sbuf_if[i].idata2;
        assign exu_sbuf_fdata[i]  = exu_sbuf_if[i].fdata1;
        assign exu_sbuf_tags[i]   = exu_sbuf_if[i].tags;
    end // exu_sbuf_rdy_genblk

    /*
     * EXECUTION UNIT ARBITRATION LOGIC
     */

    parameter int unsigned EXU_ADDR_WIDTH = $clog2(EXU_CNT);

    logic [EXU_ADDR_WIDTH-1:0] exu_idx_q;
    logic [EXU_ADDR_WIDTH-1:0] exu_idx_d;

    if(ZICSR == 1'b1) begin : wbu_reorder_genblk

        // reorder write-back enabled, arbitration is done as so
        // to keep the original instruction order
        // this prevents imprecise exceptions

    end // wbu_reorder_genblk
    if(ZICSR == 1'b0) begin : wbu_reorder_n_genblk

        // reorder write-back disabled, arbitration is done as standard round-robin

        always_comb begin
            exu_idx_d = exu_idx_q;
            for(int i = exu_idx_q; i >= 0; --i) begin
                if(exu_sbuf_rdy[i] == 1'b1) exu_idx_d = i;
            end
            for(int i = {EXU_ADDR_WIDTH{1'b1}}; i > exu_idx_q; --i) begin
                if(exu_sbuf_rdy[i] == 1'b1) exu_idx_d = i;
            end
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) exu_idx_q <= 'h0;
            else exu_idx_q <= exu_idx_d;
        end

        for(genvar i = 0; i < EXU_CNT; ++i) begin
            always_comb begin
                exu_sbuf_if[i].ack = 1'b0;
                if(exu_sbuf_if[i].rdy == 1'b0) begin
                    exu_sbuf_if[i].ack = 1'b1;
                end
                if(exu_sbuf_if[i].rdy == 1'b1 && i == exu_idx_q) begin
                    exu_sbuf_if[i].ack = 1'b1;
                end
            end
        end

    end // wbu_reorder_n_genblk

    always_comb begin
        wbu_sbuf_if.addr   = exu_sbuf_addr[exu_idx_q];
        wbu_sbuf_if.insn   = exu_sbuf_insn[exu_idx_q];
        wbu_sbuf_if.idata1 = exu_sbuf_idata1[exu_idx_q];
        wbu_sbuf_if.idata2 = exu_sbuf_idata2[exu_idx_q];
        wbu_sbuf_if.fdata1 = exu_sbuf_fdata[exu_idx_q];
        wbu_sbuf_if.tags   = exu_sbuf_tags[exu_idx_q];
        wbu_sbuf_if.rdy    = exu_sbuf_rdy[exu_idx_q];
    end

    /*
     * INTEGER REGISTER WRITE-BACK LOGIC
     */

    always_comb begin
        rfi_if.we = 1'b0;
        case(wbu_sbuf_if.opcode)
            LUI:        rfi_if.we = 1'b1;
            AUIPC:      rfi_if.we = 1'b1;
            JAL:        rfi_if.we = 1'b1;
            JALR:       rfi_if.we = 1'b1;
            LOAD:       rfi_if.we = 1'b1;
            OP_IMM:     rfi_if.we = 1'b1;
            OP:         rfi_if.we = 1'b1;
            OP_IMM_32:  rfi_if.we = 1'b1;
            OP_32:      rfi_if.we = 1'b1;
            default:    rfi_if.we = 1'b0;
        endcase
        if(wbu_sbuf_if.rdy == 1'b0) rfi_if.we = 1'b0;
    end

    assign rfi_if.waddr = wbu_sbuf_if.rd;
    assign rfi_if.wdata = wbu_sbuf_if.idata1;

    /*
     * FLOATING-POINT REGISTER WRITE-BACK LOGIC
     */

    always_comb begin
        rff_if.we = 1'b0;
        case(wbu_sbuf_if.opcode)
            LOAD_FP:    rff_if.we = 1'b1;
            OP_FP:      rff_if.we = 1'b1;
            default:    rff_if.we = 1'b0;
        endcase
        if(wbu_sbuf_if.rdy == 1'b0) rff_if.we = 1'b0;
    end

    assign rff_if.waddr = wbu_sbuf_if.rd;
    assign rff_if.wdata = wbu_sbuf_if.fdata1;

    /*
     * CONTROL TRANSFER LOGIC
     */

    always_comb begin
        ct_trans_o = 1'b0;
        case(wbu_sbuf_if.opcode)
            JAL:    ct_trans_o = 1'b1;
            JALR:   ct_trans_o = 1'b1;
            BRANCH: ct_trans_o = ^wbu_sbuf_if.tags[1:0];
        endcase
        if(wbu_sbuf_if.rdy == 1'b0) ct_trans_o = 1'b0;
    end

    assign ct_target_o = wbu_sbuf_if.idata2;

endmodule : rv0_wbu
