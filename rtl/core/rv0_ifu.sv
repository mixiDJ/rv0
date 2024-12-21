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
// Name: rv0_ifu.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc: Instruction fetch unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_ifu #(`RV0_CORE_PARAM_LST) (

    input  logic                        clk_i,
    input  logic                        rst_ni,

    // instruction fetch unit flush
    input  logic                        ifu_flush_i,

    // control transfer signals
    input  logic [XLEN-1:0]             ct_target_i,
    input  logic                        ct_trans_i,

    // pipeline buffer interface
    rv_sbuf_if.source                   ifu_sbuf_if,
    // instruction memory interface
    ahb_if.requester                    imem_if

);

    logic [XLEN-1:0]    pc_q;
    logic [XLEN-1:0]    pc_d;

    logic [31:0]        sbuf_insn;
    logic [XLEN-1:0]    sbuf_addr;
    logic               sbuf_rdy;
    logic               sbuf_ack;

    logic [XLEN-1:0]    pend_addr_q;
    logic [XLEN-1:0]    pend_addr_d;

    /*
     * INSTRUCTION FETCH FSM LOGIC
     */

    typedef enum logic [5:0] {
        S_IDLE       = 6'b000001,
        S_REQ_NONSEQ = 6'b000010,
        S_REQ_SEQ    = 6'b000100,
        S_PEND_RSP   = 6'b010000,
        S_PEND_ACK   = 6'b100000
    } imem_fsm_state_e;

    imem_fsm_state_e imem_fsm_state_q;
    imem_fsm_state_e imem_fsm_state_d;

    always_comb begin
        imem_fsm_state_d = imem_fsm_state_q;

        case(imem_fsm_state_q)
            S_IDLE: begin
                if(sbuf_ack == 1'b1) begin
                    imem_fsm_state_d = S_REQ_NONSEQ;
                end
            end

            S_REQ_NONSEQ: begin
                if(imem_if.hreadyout == 1'b1) begin
                    imem_fsm_state_d = S_REQ_SEQ;
                end
                else begin
                    imem_fsm_state_d = S_PEND_RSP;
                end
            end

            S_REQ_SEQ: begin
                if(sbuf_ack == 1'b0) begin
                    imem_fsm_state_d = S_PEND_ACK;
                end
                if(imem_if.hreadyout == 1'b0) begin
                    imem_fsm_state_d = S_PEND_RSP;
                end
            end

            S_PEND_RSP: begin
                if(imem_if.hreadyout == 1'b1) begin
                    imem_fsm_state_d = S_REQ_SEQ;
                end
            end

            S_PEND_ACK: begin
                if(sbuf_ack == 1'b1) begin
                    imem_fsm_state_d = S_IDLE;
                end
            end
        endcase

        if(ct_trans_i == 1'b1) imem_fsm_state_d = S_IDLE;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) imem_fsm_state_q <= S_IDLE;
        else imem_fsm_state_q <= imem_fsm_state_d;
    end

    /*
     * PROGRAM COUNTER LOGIC
     */

    always_comb begin
        pc_d = pc_q;

        case(imem_fsm_state_q)
            S_REQ_NONSEQ: pc_d = pc_q + 'h4;
            S_REQ_SEQ:    pc_d = pc_q + 'h4;
        endcase

        case(imem_fsm_state_d)
            S_PEND_ACK:   pc_d = pc_q;
            S_PEND_RSP:   pc_d = pc_q;
        endcase

        if(ct_trans_i == 1'b1) begin
            pc_d = ct_target_i;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) pc_q <= PC_RST_VAL;
        else pc_q <= pc_d;
    end

    /*
     * IMEM INTERFACE LOGIC
     */

    always_comb begin
        imem_if.haddr = pc_q;
    end

    always_comb begin
        imem_if.htrans = 'h0;
        case(imem_fsm_state_q)
            S_REQ_NONSEQ: imem_if.htrans = HTRANS_NONSEQ;
            S_REQ_SEQ:    imem_if.htrans = HTRANS_SEQ;
            default:      imem_if.htrans = HTRANS_IDLE;
        endcase

        if(sbuf_ack == 1'b0) imem_if.htrans = HTRANS_IDLE;
    end

    assign imem_if.hsel = 1'b1;

    /*
     * SKID BUFFER LOGIC
     */

    always_comb begin
        pend_addr_d = pend_addr_q;

        case(imem_fsm_state_q)
            S_REQ_NONSEQ: pend_addr_d = pc_q;
            S_REQ_SEQ:    pend_addr_d = pc_q;
        endcase

        if(imem_fsm_state_d == S_PEND_ACK) begin
            pend_addr_d = pend_addr_q;
        end

        if(imem_fsm_state_d == S_PEND_RSP) begin
            pend_addr_d = pend_addr_q;
        end

    end

    always_ff @(posedge clk_i) begin
        pend_addr_q <= pend_addr_d;
    end

    always_comb begin
        sbuf_rdy = 1'b0;
        case(imem_fsm_state_q)
            S_REQ_SEQ:     sbuf_rdy = 1'b1;
            S_PEND_ACK:    sbuf_rdy = 1'b1;
        endcase

        if(imem_if.hreadyout == 1'b0) begin
            sbuf_rdy = 1'b0;
        end
    end

    assign sbuf_insn = imem_if.hrdata;
    assign sbuf_addr = pend_addr_q;

    rv0_sbuf #(XLEN, FLEN)
    u_ifu_sbuf (
        .clk_i      (clk_i          ),
        .rst_ni     (rst_ni         ),
        .flush_i    (ifu_flush_i    ),
        .insn_i     (sbuf_insn      ),
        .addr_i     (sbuf_addr      ),
        .rdy_i      (sbuf_rdy       ),
        .ack_o      (sbuf_ack       ),
        .sbuf_if    (ifu_sbuf_if    )
    );

endmodule : rv0_ifu
