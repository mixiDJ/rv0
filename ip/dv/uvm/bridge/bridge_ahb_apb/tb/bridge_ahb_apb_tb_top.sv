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
// Name: bridge_ahb_apb_tb_top.sv
// Auth: Nikola Lukić
// Date: 02.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_TB_TOP_SV
`define BRIDGE_AHB_APB_TB_TOP_SV

module bridge_ahb_apb_tb_top;

    localparam int unsigned ADDR_WIDTH      = 32;
    localparam int unsigned DATA_WIDTH      = 32;
    localparam int unsigned HBURST_WIDTH    = 4;
    localparam int unsigned HPROT_WIDTH     = 4;
    localparam int unsigned HMASTER_WIDTH   = 1;
    localparam int unsigned USER_REQ_WIDTH  = 4;
    localparam int unsigned USER_DATA_WIDTH = 4;
    localparam int unsigned USER_RESP_WIDTH = 4;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "ahb_uvc_pkg.sv"
    import ahb_uvc_pkg::*;
    `include "apb_uvc_pkg.sv"
    import apb_uvc_pkg::*;
    `include "clk_uvc_pkg.sv"
    import clk_uvc_pkg::*;

    `include "bridge_ahb_apb_test_pkg.sv"
    import bridge_ahb_apb_test_pkg::*;

    clk_uvc_if ahb_clk_if();

    ahb_uvc_if #(`AHB_UVC_PARAM_LST)
    ahb_if(ahb_clk_if.clk, ahb_clk_if.rst_n);

    clk_uvc_if apb_clk_if();

    apb_uvc_if #(`APB_UVC_PARAM_LST)
    apb_if(apb_clk_if.clk, apb_clk_if.rst_n);

    bridge_ahb_apb #(`BRIDGE_AHB_APB_PARAM_LST)
    DUT (
        .hclk_i         (ahb_if.hclk        ),
        .hrst_ni        (ahb_if.hrst_n      ),
        .haddr_i        (ahb_if.haddr       ),
        .hburst_i       (ahb_if.hburst      ),
        .hmastlock_i    (ahb_if.hmastlock   ),
        .hprot_i        (ahb_if.hprot       ),
        .hsize_i        (ahb_if.hsize       ),
        .hnonsec_i      (ahb_if.hnonsec     ),
        .hexcl_i        (ahb_if.hexcl       ),
        .hmaster_i      (ahb_if.hmaster     ),
        .htrans_i       (ahb_if.htrans      ),
        .hwdata_i       (ahb_if.hwdata      ),
        .hwstrb_i       (ahb_if.hwstrb      ),
        .hwrite_i       (ahb_if.hwrite      ),
        .hsel_i         (ahb_if.hsel        ),
        .hrdata_o       (ahb_if.hrdata      ),
        .hreadyout_o    (ahb_if.hreadyout   ),
        .hresp_o        (ahb_if.hresp       ),
        .hexokay_o      (ahb_if.hexokay     ),
        .hauser_i       (ahb_if.hauser      ),
        .hwuser_i       (ahb_if.hwuser      ),
        .hruser_o       (ahb_if.hruser      ),
        .hbuser_o       (ahb_if.hbuser      ),

        .pclk_i         (apb_if.pclk        ),
        .prst_ni        (apb_if.prst_n      ),
        .paddr_o        (apb_if.paddr       ),
        .pprot_o        (apb_if.pprot       ),
        .pnse_o         (apb_if.pnse        ),
        .psel_o         (apb_if.psel        ),
        .penable_o      (apb_if.penable     ),
        .pwrite_o       (apb_if.pwrite      ),
        .pwdata_o       (apb_if.pwdata      ),
        .pstrb_o        (apb_if.pstrb       ),
        .pready_i       (apb_if.pready      ),
        .prdata_i       (apb_if.prdata      ),
        .pslverr_i      (apb_if.pslverr     ),
        .pwakeup_o      (apb_if.pwakeup     ),
        .pauser_o       (apb_if.pauser      ),
        .pwuser_o       (apb_if.pwuser      ),
        .pruser_i       (apb_if.pruser      ),
        .pbuser_i       (apb_if.pbuser      )
    );

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual ahb_uvc_if#(`AHB_UVC_PARAM_LST),
            uvm_root::get(),
            "uvm_test_top.m_env.m_ahb_env.m_master_agent",
            "m_vif",
            ahb_if
        )

        `uvm_config_db_set(
            virtual apb_uvc_if#(`APB_UVC_PARAM_LST),
            uvm_root::get(),
            "uvm_test_top.m_env.m_apb_env.m_slave_agent",
            "m_vif",
            apb_if
        )

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_0",
            "m_vif",
            ahb_clk_if
        )

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_1",
            "m_vif",
            apb_clk_if
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : bridge_ahb_apb_tb_top

`endif // BRIDGE_AHB_APB_TB_TOP
