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
// Name: xbar_ahb_tb_top.sv
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

`ifndef XBAR_AHB_TB_TOP_SV
`define XBAR_AHB_TB_TOP_SV

`include "xbar_ahb_tb_top_defs.sv"

module xbar_ahb_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "clk_uvc_pkg.sv"
    import clk_uvc_pkg::*;
    `include "ahb_uvc_pkg.sv"
    import ahb_uvc_pkg::*;

    `include "xbar_ahb_pkg.sv"
    import xbar_ahb_pkg::*;
    `include "xbar_ahb_test_pkg.sv"
    import xbar_ahb_test_pkg::*;

    localparam int unsigned         ADDR_WIDTH          = `ADDR_WIDTH;
    localparam int unsigned         DATA_WIDTH          = `DATA_WIDTH;
    localparam int unsigned         HBURST_WIDTH        = `HBURST_WIDTH;
    localparam int unsigned         HPROT_WIDTH         = `HPROT_WIDTH;
    localparam int unsigned         HMASTER_WIDTH       = `HMASTER_WIDTH;
    localparam int unsigned         USER_REQ_WIDTH      = `USER_REQ_WIDTH;
    localparam int unsigned         USER_DATA_WIDTH     = `USER_DATA_WIDTH;
    localparam int unsigned         USER_RESP_WIDTH     = `USER_RESP_WIDTH;
    localparam int unsigned         STRB_WIDTH          = DATA_WIDTH/8;
    localparam int unsigned         XBAR_REQUESTER_CNT  = `XBAR_REQUESTER_CNT;
    localparam int unsigned         XBAR_COMPLETER_CNT  = `XBAR_COMPLETER_CNT;
    localparam bit [ADDR_WIDTH-1:0] XBAR_ADDR_BASE [0:XBAR_COMPLETER_CNT-1] = `XBAR_ADDR_BASE;
    localparam bit [ADDR_WIDTH-1:0] XBAR_ADDR_MASK [0:XBAR_COMPLETER_CNT-1] = `XBAR_ADDR_MASK;

    clk_uvc_if
    u_clk_if ();

    ahb_uvc_if #(`AHB_UVC_PARAM_LST)
    u_ahb_req_if [0:XBAR_REQUESTER_CNT-1] (u_clk_if.clk, u_clk_if.rst_n);

    ahb_uvc_if #(`AHB_UVC_PARAM_LST)
    u_ahb_cmp_if [0:XBAR_COMPLETER_CNT-1] (u_clk_if.clk, u_clk_if.rst_n);

    logic [ADDR_WIDTH-1:0]      req_haddr       [0:XBAR_REQUESTER_CNT-1];
    logic [HBURST_WIDTH-1:0]    req_hburst      [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hmastlock   [0:XBAR_REQUESTER_CNT-1];
    logic [2:0]                 req_hsize       [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hnonsec     [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hexcl       [0:XBAR_REQUESTER_CNT-1];
    logic [HMASTER_WIDTH-1:0]   req_hmaster     [0:XBAR_REQUESTER_CNT-1];
    logic [1:0]                 req_htrans      [0:XBAR_REQUESTER_CNT-1];
    logic [DATA_WIDTH-1:0]      req_hwdata      [0:XBAR_REQUESTER_CNT-1];
    logic [STRB_WIDTH-1:0]      req_hwstrb      [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hwrite      [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hsel        [0:XBAR_REQUESTER_CNT-1];
    logic [DATA_WIDTH-1:0]      req_hrdata      [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hreadyout   [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hresp       [0:XBAR_REQUESTER_CNT-1];
    logic                       req_hexokay     [0:XBAR_REQUESTER_CNT-1];
    logic [USER_REQ_WIDTH-1:0]  req_hauser      [0:XBAR_REQUESTER_CNT-1];
    logic [USER_DATA_WIDTH-1:0] req_hwuser      [0:XBAR_REQUESTER_CNT-1];
    logic [USER_DATA_WIDTH-1:0] req_hruser      [0:XBAR_REQUESTER_CNT-1];
    logic [USER_RESP_WIDTH-1:0] req_hbuser      [0:XBAR_REQUESTER_CNT-1];

    logic [ADDR_WIDTH-1:0]      cmp_haddr       [0:XBAR_COMPLETER_CNT-1];
    logic [HBURST_WIDTH-1:0]    cmp_hburst      [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hmastlock   [0:XBAR_COMPLETER_CNT-1];
    logic [2:0]                 cmp_hsize       [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hnonsec     [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hexcl       [0:XBAR_COMPLETER_CNT-1];
    logic [HMASTER_WIDTH-1:0]   cmp_hmaster     [0:XBAR_COMPLETER_CNT-1];
    logic [1:0]                 cmp_htrans      [0:XBAR_COMPLETER_CNT-1];
    logic [DATA_WIDTH-1:0]      cmp_hwdata      [0:XBAR_COMPLETER_CNT-1];
    logic [STRB_WIDTH-1:0]      cmp_hwstrb      [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hwrite      [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hsel        [0:XBAR_COMPLETER_CNT-1];
    logic [DATA_WIDTH-1:0]      cmp_hrdata      [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hreadyout   [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hresp       [0:XBAR_COMPLETER_CNT-1];
    logic                       cmp_hexokay     [0:XBAR_COMPLETER_CNT-1];
    logic [USER_REQ_WIDTH-1:0]  cmp_hauser      [0:XBAR_COMPLETER_CNT-1];
    logic [USER_DATA_WIDTH-1:0] cmp_hwuser      [0:XBAR_COMPLETER_CNT-1];
    logic [USER_DATA_WIDTH-1:0] cmp_hruser      [0:XBAR_COMPLETER_CNT-1];
    logic [USER_RESP_WIDTH-1:0] cmp_hbuser      [0:XBAR_COMPLETER_CNT-1];

    for(genvar i = 0; i < XBAR_REQUESTER_CNT; ++i) begin
        assign req_haddr[i]                 = u_ahb_req_if[i].haddr;
        assign req_hburst[i]                = u_ahb_req_if[i].hburst;
        assign req_hmastlock[i]             = u_ahb_req_if[i].hmastlock;
        assign req_hsize[i]                 = u_ahb_req_if[i].hsize;
        assign req_hnonsec[i]               = u_ahb_req_if[i].hnonsec;
        assign req_hexcl[i]                 = u_ahb_req_if[i].hexcl;
        assign req_hmaster[i]               = u_ahb_req_if[i].hmaster;
        assign req_htrans[i]                = u_ahb_req_if[i].htrans;
        assign req_hwdata[i]                = u_ahb_req_if[i].hwdata;
        assign req_hwstrb[i]                = u_ahb_req_if[i].hwstrb;
        assign req_hwrite[i]                = u_ahb_req_if[i].hwrite;
        assign req_hsel[i]                  = u_ahb_req_if[i].hsel;
        assign u_ahb_req_if[i].hrdata       = req_hrdata[i];
        assign u_ahb_req_if[i].hreadyout    = req_hreadyout[i];
        assign u_ahb_req_if[i].hresp        = req_hresp[i];
        assign u_ahb_req_if[i].hexokay      = req_hexokay[i];
        assign req_hauser[i]                = u_ahb_req_if[i].hauser;
        assign req_hwuser[i]                = u_ahb_req_if[i].hwuser;
        assign u_ahb_req_if[i].hruser       = req_hruser[i];
        assign u_ahb_req_if[i].hbuser       = req_hbuser[i];
    end

    for(genvar i = 0; i < XBAR_COMPLETER_CNT; ++i) begin
        assign u_ahb_cmp_if[i].haddr        = cmp_haddr[i];
        assign u_ahb_cmp_if[i].hburst       = cmp_hburst[i];
        assign u_ahb_cmp_if[i].hmastlock    = cmp_hmastlock[i];
        assign u_ahb_cmp_if[i].hsize        = cmp_hsize[i];
        assign u_ahb_cmp_if[i].hnonsec      = cmp_hnonsec[i];
        assign u_ahb_cmp_if[i].hexcl        = cmp_hexcl[i];
        assign u_ahb_cmp_if[i].hmaster      = cmp_hmaster[i];
        assign u_ahb_cmp_if[i].htrans       = cmp_htrans[i];
        assign u_ahb_cmp_if[i].hwdata       = cmp_hwdata[i];
        assign u_ahb_cmp_if[i].hwstrb       = cmp_hwstrb[i];
        assign u_ahb_cmp_if[i].hwrite       = cmp_hwrite[i];
        assign u_ahb_cmp_if[i].hsel         = cmp_hsel[i];
        assign cmp_hrdata[i]                = u_ahb_cmp_if[i].hrdata;
        assign cmp_hreadyout[i]             = u_ahb_cmp_if[i].hreadyout;
        assign cmp_hresp[i]                 = u_ahb_cmp_if[i].hresp;
        assign cmp_hexokay[i]               = u_ahb_cmp_if[i].hexokay;
        assign u_ahb_cmp_if[i].hauser       = cmp_hauser[i];
        assign u_ahb_cmp_if[i].hwuser       = cmp_hwuser[i];
        assign cmp_hruser[i]                = u_ahb_cmp_if[i].hruser;
        assign cmp_hbuser[i]                = u_ahb_cmp_if[i].hbuser;
    end

    xbar_ahb_top #(`XBAR_AHB_PARAM_LST)
    DUT (
        .hclk_i         (u_clk_if.clk                   ),
        .hrst_ni        (u_clk_if.rst_n                 ),

        .haddr_i        (req_haddr                      ),
        .hburst_i       (req_hburst                     ),
        .hmastlock_i    (req_hmastlock                  ),
        .hsize_i        (req_hsize                      ),
        .hnonsec_i      (req_hnonsec                    ),
        .hexcl_i        (req_hexcl                      ),
        .hmaster_i      (req_hmaster                    ),
        .htrans_i       (req_htrans                     ),
        .hwdata_i       (req_hwdata                     ),
        .hwstrb_i       (req_hwstrb                     ),
        .hwrite_i       (req_hwrite                     ),
        .hsel_i         (req_hsel                       ),
        .hrdata_o       (req_hrdata                     ),
        .hreadyout_o    (req_hreadyout                  ),
        .hresp_o        (req_hresp                      ),
        .hexokay_o      (req_hexokay                    ),
        .hauser_i       (req_hauser                     ),
        .hwuser_i       (req_hwuser                     ),
        .hruser_o       (req_hruser                     ),
        .hbuser_o       (req_hbuser                     ),

        .haddr_o        (cmp_haddr                      ),
        .hburst_o       (cmp_hburst                     ),
        .hmastlock_o    (cmp_hmastlock                  ),
        .hsize_o        (cmp_hsize                      ),
        .hnonsec_o      (cmp_hnonsec                    ),
        .hexcl_o        (cmp_hexcl                      ),
        .hmaster_o      (cmp_hmaster                    ),
        .htrans_o       (cmp_htrans                     ),
        .hwdata_o       (cmp_hwdata                     ),
        .hwstrb_o       (cmp_hwstrb                     ),
        .hwrite_o       (cmp_hwrite                     ),
        .hsel_o         (cmp_hsel                       ),
        .hrdata_i       (cmp_hrdata                     ),
        .hreadyout_i    (cmp_hreadyout                  ),
        .hresp_i        (cmp_hresp                      ),
        .hexokay_i      (cmp_hexokay                    ),
        .hauser_o       (cmp_hauser                     ),
        .hwuser_o       (cmp_hwuser                     ),
        .hruser_i       (cmp_hruser                     ),
        .hbuser_i       (cmp_hbuser                     )
    );

    initial begin : tb_top_vif_config_blk
        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_0",
            "m_vif",
            u_clk_if
        )
    end // tb_top_clk_vif_config_blk

    for(genvar i = 0; i < XBAR_REQUESTER_CNT; ++i) begin : tb_top_ahb_req_vif_config_genblk

        initial begin : tb_top_ahb_req_vif_config_blk
            `uvm_config_db_set(
                virtual ahb_uvc_if#(`AHB_UVC_PARAM_LST),
                uvm_root::get(),
                $sformatf("uvm_test_top.m_env.m_ahb_master_env_%0d.m_master_agent", i),
                "m_vif",
                u_ahb_req_if[i]
            )
        end // tb_top_ahb_req_vif_config_blk

    end // tb_top_ahb_req_vif_config_genblk

    for(genvar i = 0; i < XBAR_COMPLETER_CNT; ++i) begin : tb_top_ahb_cmp_vif_config_genblk

        initial begin : tb_top_ahb_cmp_vif_config_blk
            `uvm_config_db_set(
                virtual ahb_uvc_if#(`AHB_UVC_PARAM_LST),
                uvm_root::get(),
                $sformatf("uvm_test_top.m_env.m_ahb_slave_env_%0d.m_slave_agent", i),
                "m_vif",
                u_ahb_cmp_if[i]
            )
        end // tb_top_ahb_cmp_vif_config_blk

    end // tb_top_ahb_cmp_vif_config_genblk

    typedef test_xbar_ahb_smoke#(`XBAR_AHB_PARAM_LST) test_xbar_ahb_smoke_t;

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : xbar_ahb_tb_top

`endif // XBAR_AHB_TB_TOP_SV
