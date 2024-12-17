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
// Name: skbuf_ahb.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module sbuf_ahb #(
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
    output logic [USER_RESP_WIDTH-1:0]  hbuser_o,

    output logic [ADDR_WIDTH-1:0]       haddr_o,
    output logic [HBURST_WIDTH-1:0]     hburst_o,
    output logic                        hmastlock_o,
    output logic [HPROT_WIDTH-1:0]      hprot_o,
    output logic [2:0]                  hsize_o,
    output logic                        hnonsec_o,
    output logic                        hexcl_o,
    output logic [HMASTER_WIDTH-1:0]    hmaster_o,
    output logic [1:0]                  htrans_o,
    output logic [DATA_WIDTH-1:0]       hwdata_o,
    output logic [STRB_WIDTH-1:0]       hwstrb_o,
    output logic                        hwrite_o,
    output logic                        hsel_o,
    input  logic [DATA_WIDTH-1:0]       hrdata_i,
    input  logic                        hreadyout_i,
    input  logic                        hresp_i,
    input  logic                        hexokay_i,
    output logic [USER_REQ_WIDTH-1:0]   hauser_o,
    output logic [USER_DATA_WIDTH-1:0]  hwuser_o,
    input  logic [USER_DATA_WIDTH-1:0]  hruser_i,
    input  logic [USER_RESP_WIDTH-1:0]  hbuser_i

);

    /*
     * PENDING REQUEST LOGIC
     */

    logic req_pend_q;
    logic req_pend_qq;

    localparam bit [1:0] HTRANS_IDLE   = 2'b00;
    localparam bit [1:0] HTRANS_BUSY   = 2'b01;
    localparam bit [1:0] HTRANS_NONSEQ = 2'b10;
    localparam bit [1:0] HTRANS_SEQ    = 2'b11;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) req_pend_qq <= 1'b0;
        else req_pend_qq <= req_pend_q;
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) req_pend_q <= 1'b0;
        else begin
            if(hreadyout_i == 1'b1 && req_pend_qq == 1'b1) req_pend_q <= 1'b0;
            if(htrans_i != HTRANS_IDLE && htrans_i != HTRANS_BUSY) req_pend_q <= 1'b1;
        end
    end

    assign hreadyout_o = ~req_pend_q;

    /*
     * REQUEST DATA LOGIC
     */

    localparam int unsigned REQ_DATA_WIDTH = ADDR_WIDTH + HBURST_WIDTH + HPROT_WIDTH +
                                             HMASTER_WIDTH + DATA_WIDTH + STRB_WIDTH +
                                             USER_REQ_WIDTH + USER_DATA_WIDTH +
                                             1 + 3 + 1 + 1 + 2 + 1;

    logic [REQ_DATA_WIDTH-1:0] req_data_q;
    logic [REQ_DATA_WIDTH-1:0] req_data_d;

    assign req_data_d = {
        haddr_i,
        hburst_i,
        hmastlock_i,
        hprot_i,
        hsize_i,
        hnonsec_i,
        hexcl_i,
        hmaster_i,
        hwstrb_i,
        hwrite_i,
        hauser_i,
        hwuser_i,
        htrans_i
    };

    assign {
        haddr_o,
        hburst_o,
        hmastlock_o,
        hprot_o,
        hsize_o,
        hnonsec_o,
        hexcl_o,
        hmaster_o,
        hwstrb_o,
        hwrite_o,
        hauser_o,
        hwuser_o,
        htrans_o
    } = req_data_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) req_data_q <= {REQ_DATA_WIDTH{1'b0}};
        else begin
            if(hreadyout_i == 1'b1) req_data_q[1:0] <= HTRANS_IDLE;
            if(htrans_i != HTRANS_IDLE && htrans_i != HTRANS_BUSY) req_data_q <= req_data_d;
        end
    end


    /*
     * REQUEST WRITE DATA LOGIC
     */

    logic wdata_pend_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) wdata_pend_q <= 1'b0;
        else wdata_pend_q <= hwrite_i == 1'b1 && htrans_i != HTRANS_IDLE && htrans_i != HTRANS_BUSY;
    end

    logic [DATA_WIDTH-1:0] req_hwdata_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b1) req_hwdata_q <= {DATA_WIDTH{1'b0}};
        else if(wdata_pend_q == 1'b1) req_hwdata_q <= hwdata_i;
    end

    assign hwdata_o = req_hwdata_q;


    /*
     * RESPONSE DATA LOGIC
     */

    localparam int unsigned RSP_DATA_WIDTH = DATA_WIDTH + USER_DATA_WIDTH + USER_RESP_WIDTH + 2;

    logic [RSP_DATA_WIDTH-1:0] rsp_data_q;
    logic [RSP_DATA_WIDTH-1:0] rsp_data_d;

    assign rsp_data_d = {
        hrdata_i,
        hresp_i,
        hexokay_i,
        hruser_i,
        hbuser_i
    };

    assign {
        hrdata_o,
        hresp_o,
        hexokay_o,
        hruser_o,
        hbuser_o
    } = rsp_data_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) rsp_data_q <= {RSP_DATA_WIDTH{1'b0}};
        else begin
            if(hreadyout_i == 1'b1) rsp_data_q <= rsp_data_d;
        end
    end

endmodule : sbuf_ahb
