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
// Name: rv0_core_cfg.sv
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

`ifndef RV0_CORE_CFG_SV
`define RV0_CORE_CFG_SV

class rv0_core_cfg extends uvm_object;

    typedef clk_uvc_cfg             clk_cfg_t;
    typedef ahb_uvc_cfg             ahb_cfg_t;
    typedef rv_layering_uvc_cfg     rv_cfg_t;
    typedef rv_iret_uvc_cfg         iret_cfg_t;

    /* ENVIRONMENT CONFIG OBJECTS */
    clk_cfg_t           clk_env_cfg  =  clk_cfg_t::type_id::create("clk_env_cfg");
    ahb_cfg_t           imem_env_cfg =  ahb_cfg_t::type_id::create("imem_env_cfg");
    ahb_cfg_t           dmem_env_cfg =  ahb_cfg_t::type_id::create("dmem_env_cfg");
    rv_cfg_t            rv_env_cfg   =   rv_cfg_t::type_id::create("rv_env_cfg");
    iret_cfg_t          iret_env_cfg = iret_cfg_t::type_id::create("iret_env_cfg");

    /* ENVIRONMENT CONFIG FIELDS */
    reg_init_type_e     reg_init     = REG_ZERO;
    string              reg_path     = "";

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(rv0_core_cfg)
        `uvm_field_object(                 clk_env_cfg,  UVM_DEFAULT)
        `uvm_field_object(                 imem_env_cfg, UVM_DEFAULT)
        `uvm_field_object(                 dmem_env_cfg, UVM_DEFAULT)
        `uvm_field_object(                 rv_env_cfg,   UVM_DEFAULT)
        `uvm_field_object(                 iret_env_cfg, UVM_DEFAULT)
        `uvm_field_enum  (reg_init_type_e, reg_init,     UVM_DEFAULT)
        `uvm_field_string(                 reg_path,     UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

endclass : rv0_core_cfg

`endif // RV0_CORE_CFG_SV
