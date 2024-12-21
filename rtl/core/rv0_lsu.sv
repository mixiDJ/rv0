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
// Name: rv0_lsu.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc: Load store unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_lsu #(`RV0_CORE_PARAM_LST) (

    input  logic                        clk_i,
    input  logic                        rst_ni,

    // execute unit flush signal
    input  logic                        exu_flush_i,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                     idu_sbuf_if,
    rv_sbuf_if.source                   exu_sbuf_if,

    // data memory interface
    ahb_if.requester                    dmem_if

);

    typedef enum logic [2:0] {
        S_IDLE    = 3'b001,
        S_LD_NSEQ = 3'b010,
        S_ST_NSEQ = 3'b100
    } lsu_fsm_state_e;

    lsu_fsm_state_e dmem_fsm_state_q;
    lsu_fsm_state_e dmem_fsm_state_d;

    /*
     * DMEM BUFFER
     */

    localparam int unsigned DMEM_BUF_WIDTH = 3*XLEN + 32;

    logic                       exu_buf_we;
    logic [DMEM_BUF_WIDTH-1:0]  exu_buf_wdata;
    logic                       exu_buf_full;
    logic                       exu_buf_re;
    logic [DMEM_BUF_WIDTH-1:0]  exu_buf_rdata;
    logic                       exu_buf_empty;

    logic [31:0]                exu_insn_q;
    logic [31:0]                exu_insn_d;
    logic [XLEN-1:0]            exu_addr_q;
    logic [XLEN-1:0]            exu_addr_d;
    logic [XLEN-1:0]            exu_idata1;
    logic [XLEN-1:0]            exu_idata2;

    logic [31:0]                exu_sbuf_insn;
    logic [XLEN-1:0]            exu_sbuf_addr;
    logic [XLEN-1:0]            exu_sbuf_idata;
    logic [FLEN-1:0]            exu_sbuf_fdata;
    logic                       exu_sbuf_rdy;
    logic                       exu_sbuf_ack;

    fifo_sync #(.DATA_WIDTH(DMEM_BUF_WIDTH))
    u_exu_buf (
        .clk_i      (clk_i              ),
        .rst_ni     (rst_ni             ),
        .clr_i      (exu_flush_i        ),
        .we_i       (exu_buf_we         ),
        .wdata_i    (exu_buf_wdata      ),
        .full_o     (exu_buf_full       ),
        .re_i       (exu_buf_re         ),
        .rdata_o    (exu_buf_rdata      ),
        .empty_o    (exu_buf_empty      )
    );

    assign exu_buf_we = idu_sbuf_if.rdy == 1'b1 && idu_sbuf_if.ack == 1'b1;

    assign exu_buf_wdata = {
        idu_sbuf_if.insn,
        idu_sbuf_if.addr,
        idu_sbuf_if.idata1,
        idu_sbuf_if.idata2
    };

    always_comb begin
        exu_buf_re = 1'b0;
        case(dmem_fsm_state_d)
            S_LD_NSEQ: exu_buf_re = dmem_if.hreadyout;
            S_ST_NSEQ: exu_buf_re = dmem_if.hreadyout;
        endcase
        if(exu_sbuf_ack == 1'b0) exu_buf_re = 1'b0;
    end

    assign {
        exu_insn_d,
        exu_addr_d,
        exu_idata1,
        exu_idata2
    } = exu_buf_rdata;

    always_ff @(posedge clk_i) begin
        if(dmem_if.hreadyout == 1'b1 && exu_sbuf_ack == 1'b1) begin
            exu_insn_q <= exu_insn_d;
            exu_addr_q <= exu_addr_d;
        end
    end

    logic buf_st;
    assign buf_st = exu_insn_d[6:0] == STORE;

    /*
     * MEMORY ACCESS FSM LOGIC
     */

    always_comb begin
        dmem_fsm_state_d = dmem_fsm_state_q;

        case(dmem_fsm_state_q)

            S_IDLE: begin
                if(exu_buf_empty == 1'b0 && buf_st == 1'b1) begin
                    dmem_fsm_state_d = S_ST_NSEQ;
                end
                if(exu_buf_empty == 1'b0 && buf_st == 1'b0) begin
                    dmem_fsm_state_d = S_LD_NSEQ;
                end
            end

            S_LD_NSEQ: begin

                if(exu_buf_empty == 1'b1) begin
                    dmem_fsm_state_d = S_IDLE;
                end
                else if(buf_st == 1'b1) begin
                    dmem_fsm_state_d = S_ST_NSEQ;
                end

                if(dmem_if.hreadyout == 1'b0) begin
                    dmem_fsm_state_d = S_LD_NSEQ;
                end

                if(exu_sbuf_ack == 1'b0) begin
                    dmem_fsm_state_d = S_IDLE;
                end
            end

            S_ST_NSEQ: begin

                if(exu_buf_empty == 1'b1) begin
                    dmem_fsm_state_d = S_IDLE;
                end
                else if(buf_st == 1'b0) begin
                    dmem_fsm_state_d = S_LD_NSEQ;
                end

                if(dmem_if.hreadyout == 1'b0) begin
                    dmem_fsm_state_d = S_LD_NSEQ;
                end

                if(exu_sbuf_ack == 1'b0) begin
                    dmem_fsm_state_d = S_IDLE;
                end
            end

        endcase

    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) dmem_fsm_state_q <= S_IDLE;
        else dmem_fsm_state_q <= dmem_fsm_state_d;
    end

    /*
     * DMEM INTERFACE LOGIC
     */

    always_comb begin
        dmem_if.haddr = 'h0;
        case(dmem_fsm_state_d)
            S_LD_NSEQ: dmem_if.haddr = exu_idata1 + 'h0; // FIXME: add correct address offset
            S_ST_NSEQ: dmem_if.haddr = exu_idata1 + 'h0; // FIXME: add correct address offset
        endcase
    end

    assign dmem_if.hburst = HBURST_SINGLE;

    always_comb begin
        dmem_if.hsize = 'h0;
        case(dmem_fsm_state_d)
            S_LD_NSEQ: dmem_if.hsize = {1'b0, exu_insn_d[13:12]};
            S_ST_NSEQ: dmem_if.hsize = {1'b0, exu_insn_d[13:12]};
        endcase
    end

    always_comb begin
        dmem_if.htrans = 'h0;
        case(dmem_fsm_state_d)
            S_IDLE:    dmem_if.htrans = HTRANS_IDLE;
            S_LD_NSEQ: dmem_if.htrans = HTRANS_NONSEQ;
            S_ST_NSEQ: dmem_if.htrans = HTRANS_NONSEQ;
        endcase
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) dmem_if.hwdata <= 'h0;
        else if(dmem_fsm_state_d == S_ST_NSEQ) begin
            // FIXME: add write data masking
            dmem_if.hwdata <= exu_idata2;
        end
    end

    if(XLEN == 64) begin : hwstrb_xlen64_genblk

        always_comb begin
            dmem_if.hwstrb = 'h0;
            if(dmem_fsm_state_d == S_ST_NSEQ) begin
                case(exu_insn_d[14:12])
                    SB: dmem_if.hwstrb = 4'b0001;
                    SH: dmem_if.hwstrb = 4'b0011;
                    SW: dmem_if.hwstrb = 4'b1111;
                endcase
            end
        end

    end // hwstrb_xlen64_genblk

    if(XLEN == 32) begin : hwstrb_xlen32_genblk

        always_comb begin
            dmem_if.hwstrb = 'h0;
            if(dmem_fsm_state_d == S_ST_NSEQ) begin
                case(exu_insn_d[14:12])
                    SB: dmem_if.hwstrb = 8'b00000001;
                    SH: dmem_if.hwstrb = 8'b00000011;
                    SW: dmem_if.hwstrb = 8'b00001111;
                    SD: dmem_if.hwstrb = 8'b11111111;
                endcase
            end
        end

    end // hwstrb_xlen32_genblk

    assign dmem_if.hwrite = dmem_fsm_state_d == S_ST_NSEQ;
    assign dmem_if.hsel   = 1'b1;

    /*
     * INSTRUCTION DECODE RESPONSE LOGIC
     */

    always_comb begin
        idu_sbuf_if.ack = 1'b1;
        if(exu_buf_full == 1'b1) begin
            idu_sbuf_if.ack = 1'b0;
        end
        if(idu_sbuf_if.rdy == 1'b0) begin
            idu_sbuf_if.ack = 1'b1;
        end
    end

    /*
     * MEMORY ACCESS UNIT SKID BUFFER LOGIC
     */

    if(XLEN == 64) begin : exu_sbuf_idata_xlen64_genblk

        always_comb begin
            exu_sbuf_idata = 'h0;
            case(exu_sbuf_insn[14:12])
                LB:  exu_sbuf_idata = {{XLEN-8 {dmem_if.hrdata[7]}},  dmem_if.hrdata[7:0]};
                LH:  exu_sbuf_idata = {{XLEN-16{dmem_if.hrdata[15]}}, dmem_if.hrdata[15:0]};
                LW:  exu_sbuf_idata = {{XLEN-32{dmem_if.hrdata[31]}}, dmem_if.hrdata[31:0]};
                LD:  exu_sbuf_idata = dmem_if.hrdata;
                LBU: exu_sbuf_idata = {{XLEN-8 {1'b0}}, dmem_if.hrdata[7:0]};
                LHU: exu_sbuf_idata = {{XLEN-16{1'b0}}, dmem_if.hrdata[15:0]};
                LWU: exu_sbuf_idata = {{XLEN-32{1'b0}}, dmem_if.hrdata[31:0]};
            endcase
        end

    end // exu_sbuf_idata_xlen64_genblk

    if(XLEN == 32) begin : exu_sbuf_idata_xlen32_genblk

        always_comb begin
            exu_sbuf_idata = 'h0;
            case(exu_sbuf_insn[14:12])
                LB:  exu_sbuf_idata = {{XLEN-8 {dmem_if.hrdata[7]}},  dmem_if.hrdata[7:0]};
                LH:  exu_sbuf_idata = {{XLEN-16{dmem_if.hrdata[15]}}, dmem_if.hrdata[15:0]};
                LW:  exu_sbuf_idata = dmem_if.hrdata;
                LBU: exu_sbuf_idata = {{XLEN-8 {1'b0}}, dmem_if.hrdata[7:0]};
                LHU: exu_sbuf_idata = {{XLEN-16{1'b0}}, dmem_if.hrdata[15:0]};
            endcase
        end

    end // exu_sbuf_idata_xlen32_genblk

    logic rsp_pend_q;
    logic rsp_pend_d;

    logic ack_pend_q;
    logic ack_pend_d;

    always_comb begin
        rsp_pend_d = rsp_pend_q;
        if(dmem_if.htrans != HTRANS_IDLE && dmem_if.hreadyout == 1'b1) rsp_pend_d <= 1'b1;
        if(dmem_if.htrans == HTRANS_IDLE && dmem_if.hreadyout == 1'b1) rsp_pend_d <= 1'b0;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) rsp_pend_q <= 1'b0;
        else rsp_pend_q <= rsp_pend_d;
    end

    always_comb begin
        ack_pend_d = ack_pend_q;

        if(exu_sbuf_rdy == 1'b1 && exu_sbuf_ack == 1'b0) begin
            ack_pend_d = 1'b1;
        end

        if(exu_sbuf_ack == 1'b1) begin
            ack_pend_d = 1'b0;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) ack_pend_q <= 1'b0;
        else ack_pend_q <= ack_pend_d;
    end

    assign exu_sbuf_insn  = exu_insn_q;
    assign exu_sbuf_addr  = exu_addr_q;
    assign exu_sbuf_fdata = dmem_if.hrdata;

    always_comb begin
        exu_sbuf_rdy = 1'b0;
        case(dmem_fsm_state_q)
            S_IDLE: begin
                exu_sbuf_rdy = rsp_pend_q && dmem_if.hreadyout == 1'b1;
            end
            S_LD_NSEQ: begin
                exu_sbuf_rdy = dmem_if.hreadyout;
            end
            S_ST_NSEQ: begin
                exu_sbuf_rdy = dmem_if.hreadyout;
            end
        endcase
        if(ack_pend_q == 1'b1) begin
            exu_sbuf_rdy = 1'b1;
        end
    end

    rv0_sbuf #(XLEN, FLEN)
    u_exu_sbuf (
        .clk_i      (clk_i              ),
        .rst_ni     (rst_ni             ),
        .flush_i    (exu_flush_i        ),

        .insn_i     (exu_sbuf_insn      ),
        .addr_i     (exu_sbuf_addr      ),
        .idata1_i   (exu_sbuf_idata     ),
        .fdata1_i   (exu_sbuf_fdata     ),
        .rdy_i      (exu_sbuf_rdy       ),
        .ack_o      (exu_sbuf_ack       ),

        .sbuf_if    (exu_sbuf_if        )
    );

endmodule : rv0_lsu
