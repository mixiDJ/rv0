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
// Name: rv0_core_csr_mstatus.sv
// Auth: Nikola Lukić
// Date: 15.12.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_CSR_MSTATUS_SV
`define RV0_CORE_CSR_MSTATUS_SV

class rv0_core_csr_mstatus #(`RV0_CORE_ENV_PARAM_LST) extends uvm_reg;

    uvm_reg_field   sie;
    uvm_reg_field   mie;
    uvm_reg_field   spie;
    uvm_reg_field   ube;
    uvm_reg_field   mpie;
    uvm_reg_field   spp;
    uvm_reg_field   vs;
    uvm_reg_field   mpp;
    uvm_reg_field   fs;
    uvm_reg_field   xs;
    uvm_reg_field   mprv;
    uvm_reg_field   sum;
    uvm_reg_field   mxr;
    uvm_reg_field   tvm;
    uvm_reg_field   tw;
    uvm_reg_field   tsr;
    uvm_reg_field   uxl;
    uvm_reg_field   sxl;
    uvm_reg_field   sbe;
    uvm_reg_field   mbe;
    uvm_reg_field   sd;

    extern virtual function new(string name="rv0_core_csr_mstatus");

    extern virtual function void build();

endclass : rv0_core_csr_mstatus

function rv0_core_csr_mstatus::new(string name="rv0_core_csr_mstatus");
    super.new(name, 64, "csr_mstatus", UVM_CVR_ALL);
endfunction : new

function void rv0_core_csr_mstatus::build();
    this.sie  = uvm_reg_field::type_id::create("sie");
    this.mie  = uvm_reg_field::type_id::create("mie");
    this.spie = uvm_reg_field::type_id::create("spie");
    this.ube  = uvm_reg_field::type_id::create("ube");
    this.mpie = uvm_reg_field::type_id::create("mpie");
    this.spp  = uvm_reg_field::type_id::create("spp");
    this.vs   = uvm_reg_field::type_id::create("vs");
    this.mpp  = uvm_reg_field::type_id::create("mpp");
    this.fs   = uvm_reg_field::type_id::create("fs");
    this.xs   = uvm_reg_field::type_id::create("xs");
    this.mprv = uvm_reg_field::type_id::create("mprv");
    this.sum  = uvm_reg_field::type_id::create("sum");
    this.mxr  = uvm_reg_field::type_id::create("mxr");
    this.tvm  = uvm_reg_field::type_id::create("tvm");
    this.tw   = uvm_reg_field::type_id::create("tw");
    this.tsr  = uvm_reg_field::type_id::create("tsr");
    this.uxl  = uvm_reg_field::type_id::create("uxl");
    this.sxl  = uvm_reg_field::type_id::create("sxl");
    this.sbe  = uvm_reg_field::type_id::create("sbe");
    this.mbe  = uvm_reg_field::type_id::create("mbe");
    this.sd   = uvm_reg_field::type_id::create("sd");

    this.sie.configure  (this, 1,  1, "RW", 0, 1'b0, 1, 0, 1);
    this.mie.configure  (this, 1,  3, "RW", 0, 1'b0, 1, 0, 1);
    this.spie.configure (this, 1,  5, "RW", 1, 1'b0, 1, 0, 1);
    this.ube.configure  (this, 1,  6, "RW", 0, 1'b0, 1, 1, 1);
    this.mpie.configure (this, 1,  7, "RW", 0, 1'b0, 1, 1, 1);
    this.spp.configure  (this, 1,  8, "RW", 0, 1'b0, 1, 1, 1);
    this.vs.configure   (this, 1,  9, "RW", 0, 1'b0, 1, 1, 1);
    this.mpp.configure  (this, 1, 11, "RW", 0, 1'b0, 1, 1, 1);
    this.fs.configure   (this, 1, 13, "RW", 0, 1'b0, 1, 1, 1);
    this.xs.configure   (this, 1, 15, "RW", 0, 1'b0, 1, 1, 1);
    this.mprv.configure (this, 1, 17, "RW", 0, 1'b0, 1, 1, 1);
    this.sum.configure  (this, 1, 18, "RW", 0, 1'b0, 1, 1, 1);
    this.mxr.configure  (this, 1, 19, "RW", 0, 1'b0, 1, 1, 1);
    this.tvm.configure  (this, 1, 20, "RW", 0, 1'b0, 1, 1, 1);
    this.tw.configure   (this, 1, 21, "RW", 0, 1'b0, 1, 1, 1);
    this.tsr.configure  (this, 1, 22, "RW", 0, 1'b0, 1, 1, 1);
    this.uxl.configure  (this, 1, 32, "RW", 0, 1'b0, 1, 1, 1);
    this.sxl.configure  (this, 1, 34, "RW", 0, 1'b0, 1, 1, 1);
    this.sbe.configure  (this, 1, 36, "RW", 0, 1'b0, 1, 1, 1);
    this.mbe.configure  (this, 1, 37, "RW", 0, 1'b0, 1, 1, 1);
    this.sd.configure   (this, 1, 63, "RW", 0, 1'b0, 1, 1, 1);

endfunction : build

`endif // RV0_CORE_CSR_MSTATUS_SV
