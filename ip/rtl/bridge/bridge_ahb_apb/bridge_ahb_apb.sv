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
// Name: bridge_ahb_apb.sv
// Auth: Nikola Lukić
// Date: 08.09.2024.
// Desc: Clock domain crossing AHB-APB bridge
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module bridge_ahb_apb #(
    parameter  int unsigned ADDR_WIDTH      = 32,
    parameter  int unsigned DATA_WIDTH      = 32,
    parameter  int unsigned HBURST_WIDTH    = 0,
    parameter  int unsigned HPROT_WIDTH     = 4,
    parameter  int unsigned HMASTER_WIDTH   = 1,
    parameter  int unsigned USER_REQ_WIDTH  = 0,
    parameter  int unsigned USER_DATA_WIDTH = 0,
    parameter  int unsigned USER_RESP_WIDTH = 0,
    localparam int unsigned STRB_WIDTH      = DATA_WIDTH/8
) (

    /* AHB INTERFACE */
    input  logic                        hclk_i,
    input  logic                        hrst_ni,
    input  logic [ADDR_WIDTH-1:0]       haddr_i,
    input  logic [HBURST_WIDTH-1:0]     hburst_i,
    input  logic                        hmastlock_i,
    input  logic [HPROT_WIDTH-1:0]      hprot_i,
    input  logic [2:0]                  hsize_i,
    input  logic                        hnonsec_i,
    input  logic                        hexcl_i,
    input  logic [HMASTER_WIDTH-1:0]    hmaster_i,
    input  logic [1:0]                  htrans_i,
    input  logic [DATA_WIDTH-1:0]       hwdata_i,
    input  logic [STRB_WIDTH-1:0]       hwstrb_i,
    input  logic                        hwrite_i,
    input  logic                        hsel_i,
    output logic [DATA_WIDTH-1:0]       hrdata_o,
    output logic                        hreadyout_o,
    output logic                        hresp_o,
    output logic                        hexokay_o,
    input  logic [USER_REQ_WIDTH-1:0]   hauser_i,
    input  logic [USER_DATA_WIDTH-1:0]  hwuser_i,
    output logic [USER_DATA_WIDTH-1:0]  hruser_o,
    output logic [USER_DATA_WIDTH-1:0]  hbuser_o,

    /* APB INTERFACE */
    input  logic                        pclk_i,
    input  logic                        prst_ni,
    output logic [ADDR_WIDTH-1:0]       paddr_o,
    output logic [3:0]                  pprot_o,
    output logic                        pnse_o,
    output logic                        psel_o,
    output logic                        penable_o,
    output logic                        pwrite_o,
    output logic [DATA_WIDTH-1:0]       pwdata_o,
    output logic [STRB_WIDTH-1:0]       pstrb_o,
    input  logic                        pready_i,
    input  logic [DATA_WIDTH-1:0]       prdata_i,
    input  logic                        pslverr_i,
    output logic                        pwakeup_o,
    output logic [USER_REQ_WIDTH-1:0]   pauser_o,
    output logic [USER_DATA_WIDTH-1:0]  pwuser_o,
    input  logic [USER_DATA_WIDTH-1:0]  pruser_i,
    input  logic [USER_RESP_WIDTH-1:0]  pbuser_i

);

    localparam int unsigned REQ_FIFO_DEPTH = 4;
    localparam int unsigned REQ_DATA_WIDTH = ADDR_WIDTH + STRB_WIDTH +
                                             USER_REQ_WIDTH + USER_DATA_WIDTH + 4;

    localparam int unsigned RSP_FIFO_DEPTH = 4;
    localparam int unsigned RSP_DATA_WIDTH = USER_DATA_WIDTH + USER_RESP_WIDTH + 1;

    localparam bit [1:0] HTRANS_IDLE   = 2'b00;
    localparam bit [1:0] HTRANS_BUSY   = 2'b01;
    localparam bit [1:0] HTRANS_NONSEQ = 2'b10;
    localparam bit [1:0] HTRANS_SEQ    = 2'b11;

    logic  ahb_req_busy;
    logic  ahb_req_valid;
    assign ahb_req_valid = (htrans_i == HTRANS_NONSEQ || htrans_i == HTRANS_SEQ) &&
                           ahb_req_busy == 1'b0 && hsel_i == 1'b1 && hreadyout_o == 1'b1;

    logic                       hresp_d;
    logic [USER_DATA_WIDTH-1:0] hruser_d;
    logic [USER_RESP_WIDTH-1:0] hbuser_d;

    logic apb_req_pend_n;

    logic [ADDR_WIDTH-1:0]      paddr_d;
    logic [2:0]                 pprot_d;
    logic                       pwrite_d;
    logic [STRB_WIDTH-1:0]      pstrb_d;
    logic [USER_REQ_WIDTH-1:0]  pauser_d;
    logic [USER_DATA_WIDTH-1:0] pwuser_d;

    logic pready_sync;

    sync_pulse #(.PULSE_WIDTH(1))
    u_apb_ready_sync (
        .clk_i      (hclk_i         ),
        .rst_ni     (hrst_ni        ),
        .sig_i      (pready_i       ),
        .sync_o     (pready_sync    )
    );

    logic apb_req_access_pe;
    logic apb_req_complete;


    /*
     * REQUEST DATA SYNCHRONIZATION
     */

    logic [REQ_DATA_WIDTH-1:0] ahb_req_data;
    logic [REQ_DATA_WIDTH-1:0] apb_req_data;

    assign ahb_req_data = {
        hwuser_i,
        hauser_i,
        hwstrb_i,
        hwrite_i,
        hnonsec_i,
        hprot_i[0],
        hprot_i[1],
        haddr_i
    };

    assign {
        pwuser_d,
        pauser_d,
        pstrb_d,
        pwrite_d,
        pprot_d,
        paddr_d
    } = apb_req_data;

    fifo_async #(
        .FIFO_DEPTH (REQ_FIFO_DEPTH         ),
        .DATA_WIDTH (REQ_DATA_WIDTH         )
    )
    u_req_data_fifo (
        .wclk_i     (hclk_i                 ),
        .wrst_ni    (hrst_ni                ),
        .rclk_i     (pclk_i                 ),
        .rrst_ni    (prst_ni                ),
        .we_i       (ahb_req_valid          ),
        .wdata_i    (ahb_req_data           ),
        .full_o     (ahb_req_busy           ),
        .re_i       (apb_req_access_pe      ),
        .rdata_o    (apb_req_data           ),
        .empty_o    (apb_req_pend_n         )
    );

    logic ahb_wr_req_pend_q;
    logic ahb_wdata_valid_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) ahb_wr_req_pend_q <= 1'b0;
        else begin
            if(ahb_req_valid == 1'b1 && hwrite_i == 1'b1) ahb_wr_req_pend_q <= 1'b1;
            if(pready_sync == 1'b1) ahb_wr_req_pend_q <= 1'b0;
        end
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) ahb_wdata_valid_q <= 1'b0;
        else ahb_wdata_valid_q <= ahb_req_valid == 1'b1 && hwrite_i == 1'b1;
    end

    logic [DATA_WIDTH-1:0] pwdata_d;
    logic apb_wr_req_pend_q;
    logic apb_wr_req_pend_n;
    logic apb_rd_rsp_n;
    logic apb_wr_req_access;

    fifo_async #(
        .FIFO_DEPTH (REQ_FIFO_DEPTH         ),
        .DATA_WIDTH (DATA_WIDTH             )
    )
    u_req_wdata_fifo (
        .wclk_i     (hclk_i                 ),
        .wrst_ni    (hrst_ni                ),
        .rclk_i     (pclk_i                 ),
        .rrst_ni    (prst_ni                ),
        .we_i       (ahb_wdata_valid_q      ),
        .wdata_i    (hwdata_i               ),
        .full_o     (                       ),
        .re_i       (apb_wr_req_access      ),
        .rdata_o    (pwdata_d               ),
        .empty_o    (apb_wr_req_pend_n      )
    );


    /*
     * RESPONSE DATA SYNCHRONIZATION
     */

    logic [RSP_DATA_WIDTH-1:0] ahb_rsp_data;
    logic [RSP_DATA_WIDTH-1:0] apb_rsp_data;

    assign {
        ahb_rd_rsp_n,
        hbuser_d,
        hruser_d,
        hresp_d
    } = ahb_rsp_data;

    assign apb_rsp_data = {
        apb_wr_req_pend_q,
        pbuser_i,
        pruser_i,
        pslverr_i
    };

    logic ahb_rsp_pend_q;
    logic ahb_rsp_valid_n;

    logic ahb_rsp_done;
    assign ahb_rsp_done = hreadyout_o == 1'b1 && ahb_rsp_pend_q == 1'b1;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) ahb_rsp_pend_q <= 1'b0;
        else begin
            if(ahb_rsp_done == 1'b1) ahb_rsp_pend_q <= 1'b0;
            if(ahb_req_valid == 1'b1) ahb_rsp_pend_q <= 1'b1;
        end
    end

    fifo_async #(
        .FIFO_DEPTH (RSP_FIFO_DEPTH         ),
        .DATA_WIDTH (RSP_DATA_WIDTH         )
    )
    u_rsp_data_fifo (
        .wclk_i     (pclk_i                 ),
        .wrst_ni    (prst_ni                ),
        .rclk_i     (hclk_i                 ),
        .rrst_ni    (hrst_ni                ),
        .we_i       (apb_req_complete       ),
        .wdata_i    (apb_rsp_data           ),
        .full_o     (                       ),
        .re_i       (ahb_rsp_done           ),
        .rdata_o    (ahb_rsp_data           ),
        .empty_o    (ahb_rsp_valid_n        )
    );

    logic apb_rdata_valid;
    assign apb_rdata_valid = pready_i == 1'b1 && apb_wr_req_pend_q == 1'b0;

    logic ahb_rdata_valid_n;
    logic ahb_rdata_done;
    assign ahb_rdata_done = hreadyout_o == 1'b1 && ahb_rdata_valid_n == 1'b0;

    logic [DATA_WIDTH-1:0] hrdata_d;

    fifo_async #(
        .FIFO_DEPTH (RSP_FIFO_DEPTH         ),
        .DATA_WIDTH (DATA_WIDTH             )
    )
    u_rsp_rdata_fifo (
        .wclk_i     (pclk_i                 ),
        .wrst_ni    (prst_ni                ),
        .rclk_i     (hclk_i                 ),
        .rrst_ni    (hrst_ni                ),
        .we_i       (apb_rdata_valid        ),
        .wdata_i    (prdata_i               ),
        .full_o     (                       ),
        .re_i       (ahb_rdata_done         ),
        .rdata_o    (hrdata_d               ),
        .empty_o    (ahb_rdata_valid_n      )
    );


    /*
     * AHB CONTROL LOGIC
     */

    localparam bit [1:0] S_AHB_IDLE = 2'b01;
    localparam bit [1:0] S_AHB_PEND = 2'b10;

    logic [1:0] ahb_rsp_fsm_state_q;
    logic [1:0] ahb_rsp_fsm_state_d;

    always_comb begin
        ahb_rsp_fsm_state_d = ahb_rsp_fsm_state_q;

        case(ahb_rsp_fsm_state_q)
            S_AHB_IDLE: begin
                if(ahb_req_valid == 1'b1) begin
                    ahb_rsp_fsm_state_d = S_AHB_PEND;
                end
            end

            S_AHB_PEND: begin
                if(pready_sync == 1'b1) begin
                    ahb_rsp_fsm_state_d = S_AHB_IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) ahb_rsp_fsm_state_q <= S_AHB_IDLE;
        else ahb_rsp_fsm_state_q <= ahb_rsp_fsm_state_d;
    end


    /*
     * AHB INTERFACE LOGIC
     */

    logic ahb_rsp_valid;
    assign ahb_rsp_valid = ahb_rsp_valid_n == 1'b0 && (ahb_wr_req_pend_q == 1'b0 || ahb_rdata_valid_n == 1'b0);

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) hreadyout_o <= 1'b1;
        else begin
            if(ahb_rsp_valid == 1'b1) hreadyout_o <= 1'b1;
            if(ahb_req_valid == 1'b1) hreadyout_o <= 1'b0;
        end
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) hrdata_o <= {DATA_WIDTH{1'b0}};
        else if(ahb_rdata_valid_n == 1'b0) begin
            hrdata_o <= hrdata_d;
        end
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) hresp_o <= 1'b0;
        else if(ahb_rsp_valid == 1'b1) hresp_o <= hresp_d;
    end

    if(USER_DATA_WIDTH > 0) begin
        always_ff @(posedge hclk_i or negedge hrst_ni) begin
            if(hrst_ni == 1'b0) hruser_o <= {USER_DATA_WIDTH{1'b0}};
            else if(ahb_rsp_valid == 1'b1) hruser_o <= hruser_d;
        end
    end

    if(USER_RESP_WIDTH > 0) begin
        always_ff @(posedge hclk_i or negedge hrst_ni) begin
            if(hrst_ni == 1'b0) hbuser_o <= {USER_RESP_WIDTH{1'b0}};
            else if(ahb_rsp_valid == 1'b1) hbuser_o <= hbuser_d;
        end
    end


    /*
     * APB CONTROL LOGIC
     */

    localparam bit [3:0] S_APB_IDLE   = 4'b0001;
    localparam bit [3:0] S_APB_SETUP  = 4'b0010;
    localparam bit [3:0] S_APB_ACCESS = 4'b0100;

    logic [2:0] apb_req_fsm_state_q;
    logic [2:0] apb_req_fsm_state_d;

    always_comb begin
        apb_req_fsm_state_d = apb_req_fsm_state_q;

        case(apb_req_fsm_state_q)

            S_APB_IDLE: begin
                if(apb_req_pend_n == 1'b0) begin
                    apb_req_fsm_state_d = S_APB_SETUP;
                end

                if(pwrite_d == 1'b1 && apb_wr_req_pend_n == 1'b1) begin
                    apb_req_fsm_state_d = S_APB_IDLE;
                end
            end

            S_APB_SETUP: begin
                apb_req_fsm_state_d = S_APB_ACCESS;
            end

            S_APB_ACCESS: begin
                apb_req_fsm_state_d = S_APB_IDLE;

                if(pready_i == 1'b0) begin
                    apb_req_fsm_state_d = S_APB_ACCESS;
                end
            end

        endcase
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) apb_req_fsm_state_q <= S_APB_IDLE;
        else apb_req_fsm_state_q <= apb_req_fsm_state_d;
    end

    assign apb_req_access_pe = apb_req_fsm_state_d == S_APB_ACCESS &&
                               apb_req_fsm_state_q != S_APB_ACCESS;
    assign apb_req_complete  = apb_req_fsm_state_q == S_APB_ACCESS && pready_i == 1'b1;
    assign apb_wr_req_access = apb_req_complete == 1'b1 && apb_wr_req_pend_q == 1'b1;

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) apb_wr_req_pend_q <= 1'b0;
        else apb_wr_req_pend_q <= ~apb_wr_req_pend_n;
    end

    /*
     * APB INTERFACE LOGIC
     */

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) paddr_o <= {ADDR_WIDTH{1'b0}};
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  paddr_o <= {ADDR_WIDTH{1'b0}};
            if(apb_req_fsm_state_d == S_APB_SETUP) paddr_o <= paddr_d;
        end
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pprot_o <= 3'b000;
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pprot_o <= 3'b000;
            if(apb_req_fsm_state_d == S_APB_SETUP) pprot_o <= pprot_d;
        end
    end

    assign pnse_o = 1'b0;

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) psel_o <= 1'b0;
        else begin
            case(apb_req_fsm_state_d)
                S_APB_IDLE  : psel_o <= 1'b0;
                S_APB_SETUP : psel_o <= 1'b1;
            endcase
        end
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) penable_o <= 1'b0;
        else penable_o <= (apb_req_fsm_state_d == S_APB_ACCESS);
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pwrite_o <= 1'b0;
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pwrite_o <= 1'b0;
            if(apb_req_fsm_state_d == S_APB_SETUP) pwrite_o <= pwrite_d;
        end
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pwdata_o <= {DATA_WIDTH{1'b0}};
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pwdata_o <= {DATA_WIDTH{1'b0}};
            if(apb_req_fsm_state_d == S_APB_SETUP) pwdata_o <= pwdata_d;
            if(apb_wr_req_pend_n == 1'b1) pwdata_o <= {DATA_WIDTH{1'b0}};
        end
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pstrb_o <= {STRB_WIDTH{1'b0}};
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pstrb_o <= {STRB_WIDTH{1'b0}};
            if(apb_req_fsm_state_d == S_APB_SETUP) pstrb_o <= pstrb_d;
        end
    end

    assign pwakeup_o = apb_req_fsm_state_d != S_APB_IDLE || apb_req_fsm_state_q != S_APB_IDLE;

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pauser_o <= {USER_REQ_WIDTH{1'b0}};
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pauser_o <= {USER_REQ_WIDTH{1'b0}};
            if(apb_req_fsm_state_d == S_APB_SETUP) pauser_o <= pauser_d;
        end
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pwuser_o <= {USER_DATA_WIDTH{1'b0}};
        else begin
            if(apb_req_fsm_state_d == S_APB_IDLE)  pwuser_o <= {USER_DATA_WIDTH{1'b0}};
            if(apb_req_fsm_state_d == S_APB_SETUP) pwuser_o <= pwuser_d;
        end
    end

    assign hexokay_o = 1'b1;

endmodule : bridge_ahb_apb
