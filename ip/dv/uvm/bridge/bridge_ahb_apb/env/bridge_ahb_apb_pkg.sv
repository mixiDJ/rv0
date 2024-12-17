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
// Name: bridge_ahb_apb_pkg.sv
// Auth: Nikola Lukić
// Date: 01.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_PKG_SV
`define BRIDGE_AHB_APB_PKG_SV

`timescale 1ns/1ps
package bridge_ahb_apb_pkg;

`include "uvm_macros.svh"
`include "uvm_utils.svh"
import uvm_pkg::*;

`include "ahb_uvc_pkg.sv"
import ahb_uvc_pkg::*;
`include "apb_uvc_pkg.sv"
import apb_uvc_pkg::*;
`include "clk_uvc_pkg.sv"
import clk_uvc_pkg::*;

`include "bridge_ahb_apb_common.sv"
`include "bridge_ahb_apb_cfg.sv"
`include "bridge_ahb_apb_cov.sv"
`include "bridge_ahb_apb_scoreboard.sv"
`include "bridge_ahb_apb_vsequencer.sv"
`include "bridge_ahb_apb_vseq_lib.sv"
`include "bridge_ahb_apb_env.sv"

endpackage : bridge_ahb_apb_pkg

`endif // BRIDGE_AHB_APB_PKG_SV
