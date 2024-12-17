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
// Name: clk_uvc_example_tb_top.sv
// Auth: Nikola Lukić
// Date: 03.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_EXAMPLE_TB_TOP_SV
`define CLK_UVC_EXAMPLE_TB_TOP_SV

module clk_uvc_example_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "clk_uvc_example_test_pkg.sv"
    import clk_uvc_example_test_pkg::*;

    clk_uvc_if clk_if_0();
    clk_uvc_if clk_if_1();
    clk_uvc_if clk_if_2();
    clk_uvc_if clk_if_3();

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_0",
            "m_vif",
            clk_if_0
        )

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_1",
            "m_vif",
            clk_if_1
        )

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_2",
            "m_vif",
            clk_if_2
        )

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_3",
            "m_vif",
            clk_if_3
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : clk_uvc_example_tb_top

`endif // CLK_UVC_EXAMPLE_TB_TOP_SV
