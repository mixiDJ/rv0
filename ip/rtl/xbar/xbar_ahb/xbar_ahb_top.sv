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
// Name: xbar_ahb_top.sv
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

module xbar_ahb_top #(
    parameter  int unsigned         ADDR_WIDTH                              = 32,
    parameter  int unsigned         DATA_WIDTH                              = 32,
    parameter  int unsigned         HBURST_WIDTH                            = 4,
    parameter  int unsigned         HPROT_WIDTH                             = 4,
    parameter  int unsigned         HMASTER_WIDTH                           = 1,
    parameter  int unsigned         USER_REQ_WIDTH                          = 0,
    parameter  int unsigned         USER_DATA_WIDTH                         = 0,
    parameter  int unsigned         USER_RESP_WIDTH                         = 0,
    localparam int unsigned         STRB_WIDTH                              = DATA_WIDTH/8,
    parameter  int unsigned         XBAR_REQUESTER_CNT                      = 4,
    parameter  int unsigned         XBAR_COMPLETER_CNT                      = 4,
    parameter  bit [ADDR_WIDTH-1:0] XBAR_ADDR_BASE [0:XBAR_COMPLETER_CNT-1] = '{default: 'h0},
    parameter  bit [ADDR_WIDTH-1:0] XBAR_ADDR_MASK [0:XBAR_COMPLETER_CNT-1] = '{default: 'h0}
) (

    input  logic                        hclk_i,
    input  logic                        hrst_ni,

    input  logic [ADDR_WIDTH-1:0]       haddr_i     [0:XBAR_REQUESTER_CNT-1],
    input  logic [HBURST_WIDTH-1:0]     hburst_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic                        hmastlock_i [0:XBAR_REQUESTER_CNT-1],
    input  logic [HPROT_WIDTH-1:0]      hprot_i     [0:XBAR_REQUESTER_CNT-1],
    input  logic [2:0]                  hsize_i     [0:XBAR_REQUESTER_CNT-1],
    input  logic                        hnonsec_i   [0:XBAR_REQUESTER_CNT-1],
    input  logic                        hexcl_i     [0:XBAR_REQUESTER_CNT-1],
    input  logic [HMASTER_WIDTH-1:0]    hmaster_i   [0:XBAR_REQUESTER_CNT-1],
    input  logic [1:0]                  htrans_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic [DATA_WIDTH-1:0]       hwdata_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic [STRB_WIDTH-1:0]       hwstrb_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic                        hwrite_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic                        hsel_i      [0:XBAR_REQUESTER_CNT-1],
    output logic [DATA_WIDTH-1:0]       hrdata_o    [0:XBAR_REQUESTER_CNT-1],
    output logic                        hreadyout_o [0:XBAR_REQUESTER_CNT-1],
    output logic                        hresp_o     [0:XBAR_REQUESTER_CNT-1],
    output logic                        hexokay_o   [0:XBAR_REQUESTER_CNT-1],
    input  logic [USER_REQ_WIDTH-1:0]   hauser_i    [0:XBAR_REQUESTER_CNT-1],
    input  logic [USER_DATA_WIDTH-1:0]  hwuser_i    [0:XBAR_REQUESTER_CNT-1],
    output logic [USER_DATA_WIDTH-1:0]  hruser_o    [0:XBAR_REQUESTER_CNT-1],
    output logic [USER_RESP_WIDTH-1:0]  hbuser_o    [0:XBAR_REQUESTER_CNT-1],

    output logic [ADDR_WIDTH-1:0]       haddr_o     [0:XBAR_COMPLETER_CNT-1],
    output logic [HBURST_WIDTH-1:0]     hburst_o    [0:XBAR_COMPLETER_CNT-1],
    output logic                        hmastlock_o [0:XBAR_COMPLETER_CNT-1],
    output logic                        hprot_o     [0:XBAR_COMPLETER_CNT-1],
    output logic [2:0]                  hsize_o     [0:XBAR_COMPLETER_CNT-1],
    output logic                        hnonsec_o   [0:XBAR_COMPLETER_CNT-1],
    output logic                        hexcl_o     [0:XBAR_COMPLETER_CNT-1],
    output logic [HMASTER_WIDTH-1:0]    hmaster_o   [0:XBAR_COMPLETER_CNT-1],
    output logic [1:0]                  htrans_o    [0:XBAR_COMPLETER_CNT-1],
    output logic [DATA_WIDTH-1:0]       hwdata_o    [0:XBAR_COMPLETER_CNT-1],
    output logic [STRB_WIDTH-1:0]       hwstrb_o    [0:XBAR_COMPLETER_CNT-1],
    output logic                        hwrite_o    [0:XBAR_COMPLETER_CNT-1],
    output logic                        hsel_o      [0:XBAR_COMPLETER_CNT-1],
    input  logic [DATA_WIDTH-1:0]       hrdata_i    [0:XBAR_COMPLETER_CNT-1],
    input  logic                        hreadyout_i [0:XBAR_COMPLETER_CNT-1],
    input  logic                        hresp_i     [0:XBAR_COMPLETER_CNT-1],
    input  logic                        hexokay_i   [0:XBAR_COMPLETER_CNT-1],
    output logic [USER_REQ_WIDTH-1:0]   hauser_o    [0:XBAR_COMPLETER_CNT-1],
    output logic [USER_DATA_WIDTH-1:0]  hwuser_o    [0:XBAR_COMPLETER_CNT-1],
    input  logic [USER_DATA_WIDTH-1:0]  hruser_i    [0:XBAR_COMPLETER_CNT-1],
    input  logic [USER_RESP_WIDTH-1:0]  hbuser_i    [0:XBAR_COMPLETER_CNT-1]

);

    let max(a, b) = a > b ? a : b;
    localparam int unsigned XBAR_ENDPOINT_CNT = max(XBAR_REQUESTER_CNT, XBAR_COMPLETER_CNT);
    localparam int unsigned XBAR_FABRIC_SIZE  = 2 ** $ceil($clog2(XBAR_ENDPOINT_CNT));
    localparam int unsigned XBAR_WIDTH        = XBAR_FABRIC_SIZE / 2;
    localparam int unsigned XBAR_DEPTH        = $clog2(XBAR_FABRIC_SIZE);
    localparam int unsigned XBAR_ID_WIDTH     = $ceil($clog2(XBAR_ENDPOINT_CNT));

    initial begin
        $display(
            $sformatf(
                "XBAR_FABRIC_SIZE = %0d\nXBAR_WIDTH = %0d\nXBAR_DEPTH = %0d",
                XBAR_FABRIC_SIZE,
                XBAR_WIDTH,
                XBAR_DEPTH
            )
        );
    end

    logic [XBAR_ID_WIDTH-1:0]   rid         [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [XBAR_ID_WIDTH-1:0]   cid         [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];

    logic [ADDR_WIDTH-1:0]      haddr       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HBURST_WIDTH-1:0]    hburst      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hmastlock   [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HPROT_WIDTH-1:0]     hprot       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [2:0]                 hsize       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hnonsec     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hexcl       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HMASTER_WIDTH-1:0]   hmaster     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [1:0]                 htrans      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [DATA_WIDTH-1:0]      hwdata      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [STRB_WIDTH-1:0]      hwstrb      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hwrite      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hsel        [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [DATA_WIDTH-1:0]      hrdata      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hreadyout   [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hresp       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       hexokay     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_REQ_WIDTH-1:0]  hauser      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_DATA_WIDTH-1:0] hwuser      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_DATA_WIDTH-1:0] hruser      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_RESP_WIDTH-1:0] hbuser      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];

    logic [XBAR_ID_WIDTH-1:0]   x_rid       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [XBAR_ID_WIDTH-1:0]   x_cid       [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];

    logic [ADDR_WIDTH-1:0]      x_haddr     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HBURST_WIDTH-1:0]    x_hburst    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hmastlock [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HPROT_WIDTH-1:0]     x_hprot     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [2:0]                 x_hsize     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hnonsec   [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hexcl     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [HMASTER_WIDTH-1:0]   x_hmaster   [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [1:0]                 x_htrans    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [DATA_WIDTH-1:0]      x_hwdata    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [STRB_WIDTH-1:0]      x_hwstrb    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hwrite    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hsel      [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [DATA_WIDTH-1:0]      x_hrdata    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hreadyout [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hresp     [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic                       x_hexokay   [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_REQ_WIDTH-1:0]  x_hauser    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_DATA_WIDTH-1:0] x_hwuser    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_DATA_WIDTH-1:0] x_hruser    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];
    logic [USER_RESP_WIDTH-1:0] x_hbuser    [0:XBAR_DEPTH][0:XBAR_WIDTH-1][0:1];

    localparam int unsigned XBAR_ADDR_WIDTH = $clog2(XBAR_WIDTH) + 1;

    function bit [XBAR_ADDR_WIDTH-1:0] rol(bit [XBAR_ADDR_WIDTH-1:0] idx);
        return ((idx >> 1) & {XBAR_ADDR_WIDTH{1'b1}}) | (idx[0] << (XBAR_ADDR_WIDTH-1));
    endfunction : rol

    for(genvar i = 0; i < XBAR_DEPTH; ++i) begin : xbar_row_genblk
        localparam bit [XBAR_ID_WIDTH-1:0] XBAR_ID_MASK = 'h1 << (XBAR_ID_WIDTH - i - 1);

        initial $display($sformatf("i=%0d;id_mask=%4b", i, XBAR_ID_MASK));

        for(genvar j = 0; j < XBAR_WIDTH; ++j) begin : xbar_col_genblk

            xbar_ahb_node #(
                .ADDR_WIDTH         (ADDR_WIDTH         ),
                .DATA_WIDTH         (DATA_WIDTH         ),
                .HBURST_WIDTH       (HBURST_WIDTH       ),
                .HPROT_WIDTH        (HPROT_WIDTH        ),
                .HMASTER_WIDTH      (HMASTER_WIDTH      ),
                .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),
                .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),
                .USER_RESP_WIDTH    (USER_RESP_WIDTH    ),
                .XBAR_ID_WIDTH      (XBAR_ID_WIDTH      ),
                .XBAR_ID_MASK       (XBAR_ID_MASK       )
            )
            u_node (
                .hclk_i             (hclk_i             ),
                .hrst_ni            (hrst_ni            ),

                // requester id
                .rid_i              (                   ),
                .rid_o              (                   ),

                // completer id
                .cid_i              (cid[i][j]          ),
                .cid_o              (x_cid[i][j]        ),

                .haddr_i            (haddr[i][j]        ),
                .hburst_i           (hburst[i][j]       ),
                .hmastlock_i        (hmastlock[i][j]    ),
                .hprot_i            (hprot[i][j]        ),
                .hsize_i            (hsize[i][j]        ),
                .hnonsec_i          (hnonsec[i][j]      ),
                .hexcl_i            (hexcl[i][j]        ),
                .hmaster_i          (hmaster[i][j]      ),
                .htrans_i           (htrans[i][j]       ),
                .hwdata_i           (hwdata[i][j]       ),
                .hwstrb_i           (hwstrb[i][j]       ),
                .hwrite_i           (hwrite[i][j]       ),
                .hsel_i             (hsel[i][j]         ),
                .hrdata_o           (hrdata[i][j]       ),
                .hreadyout_o        (hreadyout[i][j]    ),
                .hresp_o            (hresp[i][j]        ),
                .hexokay_o          (hexokay[i][j]      ),
                .hauser_i           (hauser[i][j]       ),
                .hwuser_i           (hwuser[i][j]       ),
                .hruser_o           (hruser[i][j]       ),
                .hbuser_o           (hbuser[i][j]       ),

                .haddr_o            (x_haddr[i][j]      ),
                .hburst_o           (x_hburst[i][j]     ),
                .hmastlock_o        (x_hmastlock[i][j]  ),
                .hprot_o            (x_hprot[i][j]      ),
                .hsize_o            (x_hsize[i][j]      ),
                .hnonsec_o          (x_hnonsec[i][j]    ),
                .hexcl_o            (x_hexcl[i][j]      ),
                .hmaster_o          (x_hmaster[i][j]    ),
                .htrans_o           (x_htrans[i][j]     ),
                .hwdata_o           (x_hwdata[i][j]     ),
                .hwstrb_o           (x_hwstrb[i][j]     ),
                .hwrite_o           (x_hwrite[i][j]     ),
                .hsel_o             (x_hsel[i][j]       ),
                .hrdata_i           (x_hrdata[i][j]     ),
                .hreadyout_i        (x_hreadyout[i][j]  ),
                .hresp_i            (x_hresp[i][j]      ),
                .hexokay_i          (x_hexokay[i][j]    ),
                .hauser_o           (x_hauser[i][j]     ),
                .hwuser_o           (x_hwuser[i][j]     ),
                .hruser_i           (x_hruser[i][j]     ),
                .hbuser_i           (x_hbuser[i][j]     )
            );

        end // xbar_col_genblk

        for(genvar j = 0; j < XBAR_WIDTH; ++j) begin : xbar_con_genblk

            parameter bit [XBAR_ADDR_WIDTH-1:0] idx_0 = rol({j, 1'b0});
            parameter bit [XBAR_ADDR_WIDTH-1:0] idx_1 = rol({j, 1'b1});
            parameter bit [XBAR_ADDR_WIDTH-2:0] j_0   = idx_0[XBAR_ADDR_WIDTH-1:1];
            parameter bit [XBAR_ADDR_WIDTH-2:0] j_1   = idx_1[XBAR_ADDR_WIDTH-1:1];
            parameter bit                       k_0   = idx_0[0];
            parameter bit                       k_1   = idx_1[0];

            assign cid       [i+1][j] = '{x_cid       [i][j_0][k_0], x_cid       [i][j_1][k_1]};

            assign haddr     [i+1][j] = '{x_haddr     [i][j_0][k_0], x_haddr     [i][j_1][k_1]};
            assign hburst    [i+1][j] = '{x_hburst    [i][j_0][k_0], x_hburst    [i][j_1][k_1]};
            assign hmastlock [i+1][j] = '{x_hmastlock [i][j_0][k_0], x_hmastlock [i][j_1][k_1]};
            assign hprot     [i+1][j] = '{x_hprot     [i][j_0][k_0], x_hprot     [i][j_1][k_1]};
            assign hsize     [i+1][j] = '{x_hsize     [i][j_0][k_0], x_hsize     [i][j_1][k_1]};
            assign hnonsec   [i+1][j] = '{x_hnonsec   [i][j_0][k_0], x_hnonsec   [i][j_1][k_1]};
            assign hexcl     [i+1][j] = '{x_hexcl     [i][j_0][k_0], x_hexcl     [i][j_1][k_1]};
            assign hmaster   [i+1][j] = '{x_hmaster   [i][j_0][k_0], x_hmaster   [i][j_1][k_1]};
            assign htrans    [i+1][j] = '{x_htrans    [i][j_0][k_0], x_htrans    [i][j_1][k_1]};
            assign hwdata    [i+1][j] = '{x_hwdata    [i][j_0][k_0], x_hwdata    [i][j_1][k_1]};
            assign hwstrb    [i+1][j] = '{x_hwstrb    [i][j_0][k_0], x_hwstrb    [i][j_1][k_1]};
            assign hwrite    [i+1][j] = '{x_hwrite    [i][j_0][k_0], x_hwrite    [i][j_1][k_1]};
            assign hsel      [i+1][j] = '{x_hsel      [i][j_0][k_0], x_hsel      [i][j_1][k_1]};
            assign hauser    [i+1][j] = '{x_hauser    [i][j_0][k_0], x_hauser    [i][j_1][k_1]};
            assign hwuser    [i+1][j] = '{x_hwuser    [i][j_0][k_0], x_hwuser    [i][j_1][k_1]};

            assign x_hrdata    [i][j_0][k_0] = hrdata    [i+1][j][0];
            assign x_hrdata    [i][j_1][k_1] = hrdata    [i+1][j][1];
            assign x_hreadyout [i][j_0][k_0] = hreadyout [i+1][j][0];
            assign x_hreadyout [i][j_1][k_1] = hreadyout [i+1][j][1];
            assign x_hresp     [i][j_0][k_0] = hresp     [i+1][j][0];
            assign x_hresp     [i][j_1][k_1] = hresp     [i+1][j][1];
            assign x_hexokay   [i][j_0][k_0] = hexokay   [i+1][j][0];
            assign x_hexokay   [i][j_1][k_1] = hexokay   [i+1][j][1];
            assign x_hruser    [i][j_0][k_0] = hruser    [i+1][j][0];
            assign x_hruser    [i][j_1][k_1] = hruser    [i+1][j][1];
            assign x_hbuser    [i][j_0][k_0] = hbuser    [i+1][j][0];
            assign x_hbuser    [i][j_1][k_1] = hbuser    [i+1][j][1];

        end // xbar_con_genblk

    end // xbar_row_genblk

    initial $display($sformatf("XBAR_ADDR_WIDTH=%0d", XBAR_ADDR_WIDTH));

    for(genvar j = 0; j < XBAR_WIDTH; ++j) begin : xbar_in_con_genblk
        parameter bit [XBAR_ADDR_WIDTH-1:0] idx_0 = rol({j, 1'b0});
        parameter bit [XBAR_ADDR_WIDTH-1:0] idx_1 = rol({j, 1'b1});

        initial $display($sformatf("j=%0d", j));
        initial $display($sformatf("idx_0=%0d", idx_0));
        initial $display($sformatf("idx_1=%0d", idx_1));

        assign haddr     [0][j] = '{haddr_i     [idx_0], haddr_i     [idx_1]};
        assign hburst    [0][j] = '{hburst_i    [idx_0], hburst_i    [idx_1]};
        assign hmastlock [0][j] = '{hmastlock_i [idx_0], hmastlock_i [idx_1]};
        assign hprot     [0][j] = '{hprot_i     [idx_0], hprot_i     [idx_1]};
        assign hsize     [0][j] = '{hsize_i     [idx_0], hsize_i     [idx_1]};
        assign hnonsec   [0][j] = '{hnonsec_i   [idx_0], hnonsec_i   [idx_1]};
        assign hexcl     [0][j] = '{hexcl_i     [idx_0], hexcl_i     [idx_1]};
        assign hmaster   [0][j] = '{hmaster_i   [idx_0], hmaster_i   [idx_1]};
        assign htrans    [0][j] = '{htrans_i    [idx_0], htrans_i    [idx_1]};
        assign hwdata    [0][j] = '{hwdata_i    [idx_0], hwdata_i    [idx_1]};
        assign hwstrb    [0][j] = '{hwstrb_i    [idx_0], hwstrb_i    [idx_1]};
        assign hwrite    [0][j] = '{hwrite_i    [idx_0], hwrite_i    [idx_1]};
        assign hsel      [0][j] = '{hsel_i      [idx_0], hsel_i      [idx_1]};
        assign hauser    [0][j] = '{hauser_i    [idx_0], hauser_i    [idx_1]};
        assign hwuser    [0][j] = '{hwuser_i    [idx_0], hwuser_i    [idx_1]};

        assign hrdata_o    [idx_0] = hrdata    [0][j][0];
        assign hrdata_o    [idx_1] = hrdata    [0][j][1];
        assign hreadyout_o [idx_0] = hreadyout [0][j][0];
        assign hreadyout_o [idx_1] = hreadyout [0][j][1];
        assign hresp_o     [idx_0] = hresp     [0][j][0];
        assign hresp_o     [idx_1] = hresp     [0][j][1];
        assign hexokay_o   [idx_0] = hexokay   [0][j][0];
        assign hexokay_o   [idx_1] = hexokay   [0][j][1];
        assign hruser_o    [idx_0] = hruser    [0][j][0];
        assign hruser_o    [idx_1] = hruser    [0][j][1];
        assign hbuser_o    [idx_0] = hbuser    [0][j][0];
        assign hbuser_o    [idx_1] = hbuser    [0][j][1];


        // TODO: add completer ID checks

        always_comb begin
            cid[0][j][0] = {XBAR_ID_WIDTH{1'b0}};
            //cid_valid[idx_0] = 1'b0;
            for(int k = XBAR_COMPLETER_CNT - 1; k >= 0; --k) begin
                if((haddr_i[idx_0] & XBAR_ADDR_MASK[k]) == XBAR_ADDR_BASE[k]) begin
                    cid[0][j][0] = k;
                    //cid_valid[idx_0] = 1'b1;
                end
            end
        end

        always_comb begin
            cid[0][j][1] = {XBAR_ID_WIDTH{1'b0}};
            //cid_valid[idx_1] = 1'b0;
            for(int k = XBAR_COMPLETER_CNT - 1; k >= 0; --k) begin
                if((haddr_i[idx_1] & XBAR_ADDR_MASK[k]) == XBAR_ADDR_BASE[k]) begin
                    cid[0][j][1] = k;
                    //cid_valid[idx_1] = 1'b1;
                end
            end
        end

    end // xbar_in_con_genblk

    for(genvar j = 0; j < XBAR_WIDTH; ++j) begin : xbar_out_con_genblk

        for(genvar k = 0; k < 2; ++k) begin

            assign haddr_o      [2*j+k] = x_haddr       [XBAR_DEPTH-1][j][k];
            assign hburst_o     [2*j+k] = x_hburst      [XBAR_DEPTH-1][j][k];
            assign hmastlock_o  [2*j+k] = x_hmastlock   [XBAR_DEPTH-1][j][k];
            assign hprot_o      [2*j+k] = x_hprot       [XBAR_DEPTH-1][j][k];
            assign hsize_o      [2*j+k] = x_hsize       [XBAR_DEPTH-1][j][k];
            assign hnonsec_o    [2*j+k] = x_hnonsec     [XBAR_DEPTH-1][j][k];
            assign hexcl_o      [2*j+k] = x_hexcl       [XBAR_DEPTH-1][j][k];
            assign hmaster_o    [2*j+k] = x_hmaster     [XBAR_DEPTH-1][j][k];
            assign htrans_o     [2*j+k] = x_htrans      [XBAR_DEPTH-1][j][k];
            assign hwdata_o     [2*j+k] = x_hwdata      [XBAR_DEPTH-1][j][k];
            assign hwstrb_o     [2*j+k] = x_hwstrb      [XBAR_DEPTH-1][j][k];
            assign hwrite_o     [2*j+k] = x_hwrite      [XBAR_DEPTH-1][j][k];
            //assign hsel_o       [2*j+k] = x_hsel        [XBAR_DEPTH-1][j][k];
            assign hsel_o       [2*j+k] = 1'b1;
            assign hauser_o     [2*j+k] = x_hauser      [XBAR_DEPTH-1][j][k];
            assign hwuser_o     [2*j+k] = x_hruser      [XBAR_DEPTH-1][j][k];

            assign x_hrdata     [XBAR_DEPTH-1][j][k] = hrdata_i     [2*j+k];
            assign x_hreadyout  [XBAR_DEPTH-1][j][k] = hreadyout_i  [2*j+k];
            assign x_hresp      [XBAR_DEPTH-1][j][k] = hresp_i      [2*j+k];
            assign x_hexokay    [XBAR_DEPTH-1][j][k] = hexokay_i    [2*j+k];
            assign x_hruser     [XBAR_DEPTH-1][j][k] = hruser_i     [2*j+k];
            assign x_hbuser     [XBAR_DEPTH-1][j][k] = hbuser_i     [2*j+k];

        end

    end // xbar_out_con_genblk

    /*
    always_comb begin
        for(int i = 0; i < XBAR_DEPTH; ++i) begin
            for(bit [XBAR_ADDR_WIDTH-1:0] j = 0; j < XBAR_WIDTH; ++j) begin

                bit [XBAR_ADDR_WIDTH-1:0] idx_0;
                bit [XBAR_ADDR_WIDTH-1:0] idx_1;

                bit [XBAR_ADDR_WIDTH-1:0] j_0;
                bit [XBAR_ADDR_WIDTH-1:0] j_1;
                bit                       k_0;
                bit                       k_1;

                idx_0 = rol({j, 1'b0});
                idx_1 = rol({j, 1'b1});

                j_0 = idx_0[XBAR_ADDR_WIDTH-1:1];
                j_1 = idx_1[XBAR_ADDR_WIDTH-1:1];

                k_0 = idx_0[0];
                k_1 = idx_1[0];

                haddr[i+1][j]     = '{x_haddr[i][j_1][k_1], x_haddr[i][j_0][k_0]};
                hburst[i+1][j]    = '{x_hburst[i][j_1][k_1], x_hburst[i][j_0][k_0]};
                hmastlock[i+1][j] = '{x_hmastlock[i][j_1][k_1], x_hmastlock[i][j_0][k_0]};
                hprot[i+1][j]     = '{x_hprot[i][j_1][k_1], x_hprot[i][j_0][k_0]};
                hsize[i+1][j]     = '{x_hsize[i][j_1][k_1], x_hsize[i][j_0][k_0]};
                hnonsec[i+1][j]   = '{x_hnonsec[i][j_1][k_1], x_hnonsec[i][j_0][k_0]};
                hexcl[i+1][j]     = '{x_hexcl[i][j_1][k_1], x_hexcl[i][j_0][k_0]};
                hmaster[i+1][j]   = '{x_hmaster[i][j_1][k_1], x_hmaster[i][j_0][k_0]};
                htrans[i+1][j]    = '{x_htrans[i][j_1][k_1], x_htrans[i][j_0][k_0]};
                hwdata[i+1][j]    = '{x_hwdata[i][j_1][k_1], x_hwdata[i][j_0][k_0]};
                hwstrb[i+1][j]    = '{x_hwstrb[i][j_1][k_1], x_hwstrb[i][j_0][k_0]};
                hwrite[i+1][j]    = '{x_hwrite[i][j_1][k_1], x_hwrite[i][j_0][k_0]};
                hsel[i+1][j]      = '{x_hsel[i][j_1][k_1], x_hsel[i][j_0][k_0]};
                hauser[i+1][j]    = '{x_hauser[i][j_1][k_1], x_hauser[i][j_0][k_0]};
                hwuser[i+1][j]    = '{x_hwuser[i][j_1][k_1], x_hwuser[i][j_0][k_0]};

                x_hrdata[i][j_0][k_0]    = hrdata[i+1][j][0];
                x_hrdata[i][j_1][k_1]    = hrdata[i+1][j][1];
                x_hreadyout[i][j_0][k_0] = hreadyout[i+1][j][0];
                x_hreadyout[i][j_1][k_1] = hreadyout[i+1][j][1];
                x_hresp[i][j_0][k_0]     = hresp[i+1][j][0];
                x_hresp[i][j_1][k_1]     = hresp[i+1][j][1];
                x_hexokay[i][j_0][k_0]   = hexokay[i+1][j][0];
                x_hexokay[i][j_1][k_1]   = hexokay[i+1][j][1];
                x_hruser[i][j_0][k_0]    = hruser[i+1][j][0];
                x_hruser[i][j_1][k_1]    = hruser[i+1][j][1];
                x_hbuser[i][j_0][k_0]    = hbuser[i+1][j][0];
                x_hbuser[i][j_1][k_1]    = hbuser[i+1][j][1];

            end
        end
    end
    */

endmodule : xbar_ahb_top
