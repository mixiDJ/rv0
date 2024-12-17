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
// Name: apb_uvc_example_tb_top.sv
// Auth: Nikola Lukić
// Date: 14.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_EXAMPLE_TB_TOP_SV
`define APB_UVC_EXAMPLE_TB_TOP_SV

module apb_uvc_example_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "apb_uvc_example_test_pkg.sv"
    import apb_uvc_example_test_pkg::*;

    logic pclk;
    logic prst_n;

    apb_uvc_if#(.DATA_WIDTH(64)) apb_if(pclk, prst_n);

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual apb_uvc_if#(.DATA_WIDTH(64)),
            uvm_root::get(),
            "uvm_test_top.m_env.m_apb_env.m_master_agent",
            "m_vif",
            apb_if.master
        )

        `uvm_config_db_set(
            virtual apb_uvc_if#(.DATA_WIDTH(64)),
            uvm_root::get(),
            "uvm_test_top.m_env.m_apb_env.m_slave_agent",
            "m_vif",
            apb_if.slave
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

    initial begin : tb_top_clk_blk
        pclk = 1'b1;
        forever #5 pclk <= ~pclk;
    end

    initial begin : tb_top_rst_blk
        prst_n = 1'b0;
        #201;
        prst_n = 1'b1;
    end

endmodule : apb_uvc_example_tb_top

`endif // APB_UVC_EXAMPLE_TB_TOP_SV
