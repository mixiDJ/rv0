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
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_core_pkg.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_PKG_SV
`define RV0_CORE_PKG_SV

package rv0_core_pkg;

`include "uvm_macros.svh"
`include "uvm_utils.svh"
import uvm_pkg::*;

`include "clk_uvc_pkg.sv"
import clk_uvc_pkg::*;
`include "ahb_uvc_pkg.sv"
import ahb_uvc_pkg::*;
`include "rv_uvc_pkg.sv"
import rv_uvc_pkg::*;
`include "rv_layering_uvc_pkg.sv"
import rv_layering_uvc_pkg::*;
`include "rv_layering_ahb_uvc_pkg.sv"
import rv_layering_ahb_uvc_pkg::*;
`include "rv_iret_uvc_pkg.sv"
import rv_iret_uvc_pkg::*;

`include "rv0_core_common.sv"
`include "rv0_core_cfg.sv"
`include "rv0_core_scoreboard.sv"
`include "rv0_core_dmem_scoreboard.sv"
`include "rv0_core_vsequencer.sv"
`include "rv0_core_vseq_lib.sv"
`include "rv0_core_env.sv"

endpackage : rv0_core_pkg

`endif // RV0_CORE_PKG_SV
