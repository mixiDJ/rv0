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
// Name: ahb_uvc_example_tb_top.sv
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

`ifndef AHB_UVC_EXAMPLE_TB_TOP_SV
`define AHB_UVC_EXAMPLE_TB_TOP_SV

module ahb_uvc_example_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "ahb_uvc_example_test_pkg.sv"
    import ahb_uvc_example_test_pkg::*;

    logic hclk;
    logic hrst_n;

    ahb_uvc_if#(.DATA_WIDTH(64)) ahb_if(hclk, hrst_n);

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual ahb_uvc_if#(.DATA_WIDTH(64)),
            uvm_root::get(),
            "uvm_test_top.m_env.m_ahb_env.m_master_agent",
            "m_vif",
            ahb_if.master
        )

        `uvm_config_db_set(
            virtual ahb_uvc_if#(.DATA_WIDTH(64)),
            uvm_root::get(),
            "uvm_test_top.m_env.m_ahb_env.m_slave_agent",
            "m_vif",
            ahb_if.slave
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

    initial begin : tb_top_clk_blk
        hclk = 1'b1;
        forever #5 hclk <= ~hclk;
    end

    initial begin : tb_top_rst_blk
        hrst_n = 1'b0;
        #201;
        hrst_n = 1'b1;
        #10000ns;
        hrst_n = 1'b0;
        #201ns;
        hrst_n = 1'b1;
    end

    import ahb_uvc_pkg::*;

    initial begin : tb_top_burst_address_mask_blk
        for(int i = 0; i < 8; ++i) begin
            for(int j = 0; j < 8; ++j) begin
                $display(
                    $sformatf(
                        "hsize=%3b;hburst=%3b;burst_address_mask=%32b;",
                        i,
                        j,
                        `BURST_ADDRESS_BOUNDARY_MASK(i, j, 32)
                    )
                );
            end
        end
    end

endmodule : ahb_uvc_example_tb_top

`endif // AHB_UVC_EXAMPLE_TB_TOP_SV
