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
// Name: xbar_ahb_node.sv
// Auth: Nikola Lukić
// Date: 19.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module xbar_ahb_node #(
    parameter  int unsigned             ADDR_WIDTH      = 32,
    parameter  int unsigned             DATA_WIDTH      = 32,
    parameter  int unsigned             HBURST_WIDTH    = 0,
    parameter  int unsigned             HPROT_WIDTH     = 4,
    parameter  int unsigned             HMASTER_WIDTH   = 1,
    parameter  int unsigned             USER_REQ_WIDTH  = 0,
    parameter  int unsigned             USER_DATA_WIDTH = 0,
    parameter  int unsigned             USER_RESP_WIDTH = 0,
    localparam int unsigned             STRB_WIDTH      = DATA_WIDTH/8,
    parameter  int unsigned             XBAR_ID_WIDTH   = 2,
    parameter  bit [XBAR_ID_WIDTH-1:0]  XBAR_ID_MASK    = {XBAR_ID_WIDTH{1'b0}}
) (

    input  logic                        hclk_i,
    input  logic                        hrst_ni,

    input  logic [XBAR_ID_WIDTH-1:0]    rid_i       [0:1],
    output logic [XBAR_ID_WIDTH-1:0]    rid_o       [0:1],

    input  logic [XBAR_ID_WIDTH-1:0]    cid_i       [0:1],
    output logic [XBAR_ID_WIDTH-1:0]    cid_o       [0:1],

    input  logic [ADDR_WIDTH-1:0]       haddr_i     [0:1],
    input  logic [HBURST_WIDTH-1:0]     hburst_i    [0:1],
    input  logic                        hmastlock_i [0:1],
    input  logic [HPROT_WIDTH-1:0]      hprot_i     [0:1],
    input  logic [2:0]                  hsize_i     [0:1],
    input  logic                        hnonsec_i   [0:1],
    input  logic                        hexcl_i     [0:1],
    input  logic [HMASTER_WIDTH-1:0]    hmaster_i   [0:1],
    input  logic [1:0]                  htrans_i    [0:1],
    input  logic [DATA_WIDTH-1:0]       hwdata_i    [0:1],
    input  logic [STRB_WIDTH-1:0]       hwstrb_i    [0:1],
    input  logic                        hwrite_i    [0:1],
    input  logic                        hsel_i      [0:1],
    output logic [DATA_WIDTH-1:0]       hrdata_o    [0:1],
    output logic                        hreadyout_o [0:1],
    output logic                        hresp_o     [0:1],
    output logic                        hexokay_o   [0:1],
    input  logic [USER_REQ_WIDTH-1:0]   hauser_i    [0:1],
    input  logic [USER_DATA_WIDTH-1:0]  hwuser_i    [0:1],
    output logic [USER_DATA_WIDTH-1:0]  hruser_o    [0:1],
    output logic [USER_DATA_WIDTH-1:0]  hbuser_o    [0:1],

    output logic [ADDR_WIDTH-1:0]       haddr_o     [0:1],
    output logic [HBURST_WIDTH-1:0]     hburst_o    [0:1],
    output logic                        hmastlock_o [0:1],
    output logic [HPROT_WIDTH-1:0]      hprot_o     [0:1],
    output logic [2:0]                  hsize_o     [0:1],
    output logic                        hnonsec_o   [0:1],
    output logic                        hexcl_o     [0:1],
    output logic [HMASTER_WIDTH-1:0]    hmaster_o   [0:1],
    output logic [1:0]                  htrans_o    [0:1],
    output logic [DATA_WIDTH-1:0]       hwdata_o    [0:1],
    output logic [STRB_WIDTH-1:0]       hwstrb_o    [0:1],
    output logic                        hwrite_o    [0:1],
    output logic                        hsel_o      [0:1],
    input  logic [DATA_WIDTH-1:0]       hrdata_i    [0:1],
    input  logic                        hreadyout_i [0:1],
    input  logic                        hresp_i     [0:1],
    input  logic                        hexokay_i   [0:1],
    output logic [USER_REQ_WIDTH-1:0]   hauser_o    [0:1],
    output logic [USER_DATA_WIDTH-1:0]  hwuser_o    [0:1],
    input  logic [USER_DATA_WIDTH-1:0]  hruser_i    [0:1],
    input  logic [USER_DATA_WIDTH-1:0]  hbuser_i    [0:1]

);

    /*
     * AHB REQUEST SKID BUFFERS
     */

    logic [ADDR_WIDTH-1:0]      sbuf_haddr      [0:1];
    logic [HBURST_WIDTH-1:0]    sbuf_hburst     [0:1];
    logic                       sbuf_hmastlock  [0:1];
    logic [HPROT_WIDTH-1:0]     sbuf_hprot      [0:1];
    logic [2:0]                 sbuf_hsize      [0:1];
    logic                       sbuf_hnonsec    [0:1];
    logic                       sbuf_hexcl      [0:1];
    logic [HMASTER_WIDTH-1:0]   sbuf_hmaster    [0:1];
    logic [1:0]                 sbuf_htrans     [0:1];
    logic [DATA_WIDTH-1:0]      sbuf_hwdata     [0:1];
    logic [STRB_WIDTH-1:0]      sbuf_hwstrb     [0:1];
    logic                       sbuf_hwrite     [0:1];
    logic                       sbuf_hsel       [0:1];
    logic [DATA_WIDTH-1:0]      sbuf_hrdata     [0:1];
    logic                       sbuf_hreadyout  [0:1];
    logic                       sbuf_hresp      [0:1];
    logic                       sbuf_hexokay    [0:1];
    logic [USER_REQ_WIDTH-1:0]  sbuf_hauser     [0:1];
    logic [USER_DATA_WIDTH-1:0] sbuf_hwuser     [0:1];
    logic [USER_DATA_WIDTH-1:0] sbuf_hruser     [0:1];
    logic [USER_RESP_WIDTH-1:0] sbuf_hbuser     [0:1];

    for(genvar i = 0; i < 2; ++i) begin : ahb_sbuf_genblk

        sbuf_ahb #(
            .ADDR_WIDTH         (ADDR_WIDTH         ),
            .DATA_WIDTH         (DATA_WIDTH         ),
            .HBURST_WIDTH       (HBURST_WIDTH       ),
            .HPROT_WIDTH        (HPROT_WIDTH        ),
            .HMASTER_WIDTH      (HMASTER_WIDTH      ),
            .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),
            .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),
            .USER_RESP_WIDTH    (USER_RESP_WIDTH    )
        )
        u_sbuf (
            .hclk_i             (hclk_i             ),
            .hrst_ni            (hrst_ni            ),

            .haddr_i            (haddr_i[i]         ),
            .hburst_i           (hburst_i[i]        ),
            .hmastlock_i        (hmastlock_i[i]     ),
            .hprot_i            (hprot_i[i]         ),
            .hsize_i            (hsize_i[i]         ),
            .hnonsec_i          (hnonsec_i[i]       ),
            .hexcl_i            (hexcl_i[i]         ),
            .hmaster_i          (hmaster_i[i]       ),
            .htrans_i           (htrans_i[i]        ),
            .hwdata_i           (hwdata_i[i]        ),
            .hwstrb_i           (hwstrb_i[i]        ),
            .hwrite_i           (hwrite_i[i]        ),
            .hsel_i             (hsel_i[i]          ),
            .hrdata_o           (hrdata_o[i]        ),
            .hreadyout_o        (hreadyout_o[i]     ),
            .hresp_o            (hresp_o[i]         ),
            .hexokay_o          (hexokay_o[i]       ),
            .hauser_i           (hauser_i[i]        ),
            .hwuser_i           (hwuser_i[i]        ),
            .hruser_o           (hruser_o[i]        ),
            .hbuser_o           (hbuser_o[i]        ),

            .haddr_o            (sbuf_haddr[i]      ),
            .hburst_o           (sbuf_hburst[i]     ),
            .hmastlock_o        (sbuf_hmastlock[i]  ),
            .hprot_o            (sbuf_hprot[i]      ),
            .hsize_o            (sbuf_hsize[i]      ),
            .hnonsec_o          (sbuf_hnonsec[i]    ),
            .hexcl_o            (sbuf_hexcl[i]      ),
            .hmaster_o          (sbuf_hmaster[i]    ),
            .htrans_o           (sbuf_htrans[i]     ),
            .hwdata_o           (sbuf_hwdata[i]     ),
            .hwstrb_o           (sbuf_hwstrb[i]     ),
            .hwrite_o           (sbuf_hwrite[i]     ),
            .hsel_o             (sbuf_hsel[i]       ),
            .hrdata_i           (sbuf_hrdata[i]     ),
            .hreadyout_i        (sbuf_hreadyout[i]  ),
            .hresp_i            (sbuf_hresp[i]      ),
            .hexokay_i          (sbuf_hexokay[i]    ),
            .hauser_o           (sbuf_hauser[i]     ),
            .hwuser_o           (sbuf_hwuser[i]     ),
            .hruser_i           (sbuf_hruser[i]     ),
            .hbuser_i           (sbuf_hbuser[i]     )
        );

    end // ahb_sbuf_genblk


    /*
     * NODE CROSS LOGIC
     */

    logic ready;
    assign ready = hreadyout_o[0] && hreadyout_o[1];

    logic cross_q;

    logic cross_valid_q [0:1];

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) begin
            cross_q <= 1'b0;
            cross_valid_q[0] <= 1'b0;
            cross_valid_q[1] <= 1'b0;
        end
        else begin
            if(ready == 1'b1) begin
                if( (cid_i[0] & XBAR_ID_MASK) && htrans_i[0]) begin
                    cross_q <= 1'b1;
                    cross_valid_q[0] <= 1'b1;
                end
                if(!(cid_i[1] & XBAR_ID_MASK) && htrans_i[1]) begin
                    cross_q <= 1'b1;
                    cross_valid_q[1] <= 1'b1;
                end

                if(!(cid_i[0] & XBAR_ID_MASK) && htrans_i[0]) begin
                    cross_q <= 1'b0;
                    cross_valid_q[0] <= 1'b0;
                end
                if( (cid_i[1] & XBAR_ID_MASK) && htrans_i[1]) begin
                    cross_q <= 1'b0;
                    cross_valid_q[1] <= 1'b0;
                end
            end
        end
    end

    logic [XBAR_ID_WIDTH-1:0] cid_q [0:1];

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) cid_q[0] <= 'h0;
        else cid_q[0] <= cid_i[0];
    end

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) cid_q[1] <= 'h0;
        else cid_q[1] <= cid_i[1];
    end

    for(genvar i = 0; i < 2; ++i) begin
        always_comb begin

            cid_o          [i] = cid_q          [cross_q ? !i : i];

            haddr_o        [i] = sbuf_haddr     [cross_q ? !i : i];
            hburst_o       [i] = sbuf_hburst    [cross_q ? !i : i];
            hmastlock_o    [i] = sbuf_hmastlock [cross_q ? !i : i];
            hprot_o        [i] = sbuf_hprot     [cross_q ? !i : i];
            hsize_o        [i] = sbuf_hsize     [cross_q ? !i : i];
            hnonsec_o      [i] = sbuf_hnonsec   [cross_q ? !i : i];
            hexcl_o        [i] = sbuf_hexcl     [cross_q ? !i : i];
            hmaster_o      [i] = sbuf_hmaster   [cross_q ? !i : i];
            //htrans_o       [i] = sbuf_htrans    [cross_q ? !i : i];
            if(cross_q == cross_valid_q[!i]) begin
                htrans_o [i] = sbuf_htrans [cross_q ? !i : i];
            end
            else begin
                htrans_o [i] = 2'b00;
            end
            hwdata_o       [i] = sbuf_hwdata    [cross_q ? !i : i];
            hwstrb_o       [i] = sbuf_hwstrb    [cross_q ? !i : i];
            hwrite_o       [i] = sbuf_hwrite    [cross_q ? !i : i];
            hsel_o         [i] = sbuf_hsel      [cross_q ? !i : i];
            hauser_o       [i] = sbuf_hauser    [cross_q ? !i : i];
            hwuser_o       [i] = sbuf_hwuser    [cross_q ? !i : i];

            sbuf_hrdata    [i] = hrdata_i       [cross_q ? !i : i];
            //sbuf_hreadyout [i] = hreadyout_i    [cross_q ? !i : i];
            if(cross_q == cross_valid_q[i]) begin
                sbuf_hreadyout[i] = hreadyout_i [cross_q ? !i : i];
            end
            else begin
                sbuf_hreadyout[i] = 1'b0;
            end
            sbuf_hresp     [i] = hresp_i        [cross_q ? !i : i];
            sbuf_hexokay   [i] = hexokay_i      [cross_q ? !i : i];
            sbuf_hruser    [i] = hruser_i       [cross_q ? !i : i];
            sbuf_hbuser    [i] = hbuser_i       [cross_q ? !i : i];

        end
    end


    /*
     * NODE ARBITRATION LOGIC
     */

    logic prior_q;

    always_ff @(posedge hclk_i or negedge hrst_ni) begin
        if(hrst_ni == 1'b0) prior_q <= 1'b0;
        else begin

        end
    end

endmodule : xbar_ahb_node
