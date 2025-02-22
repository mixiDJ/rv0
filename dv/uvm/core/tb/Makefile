####################################################################################################
# Copyright (C) 2024  Nikola Lukić <lukicn@protonmail.com>
# This source describes Open Hardware and is licensed under the CERN-OHL-S v2
#
# You may redistribute and modify this documentation and make products
# using it under the terms of the CERN-OHL-S v2 (https:/cern.ch/cern-ohl).
# This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
# AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-S v2
# for applicable conditions.
#
# Source location:
#
# As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
# these sources, You must maintain the Source Location visible on the
# external case of any product you make using this documentation.
#
####################################################################################################
# Name: Makefile
# Auth: Nikola Lukić
# Date: 13.11.2024.
# Desc:
#
####################################################################################################
# Change History
# -------------------------------------------------------------------------------------------------
# Date         Author  Description
# -------------------------------------------------------------------------------------------------
#
####################################################################################################

PROJECT_NAME    = rv0_core

#BASE_DIR        = $(HOME)/Projects/rv0
BASE_DIR 	= /media/sf_rv0-master
PROJECT_DIR     = $(BASE_DIR)/dv/uvm/core
WORK_DIR        = $(BASE_DIR)/work/core
IP_DIR          = $(BASE_DIR)/ip

TEST_NAME       = test_$(PROJECT_NAME)_base
SEED            = 0
VERBOSITY       = UVM_LOW
#TOP_TB_NAME     = $(PROJECT_NAME)_tb_top
TOP_TB_NAME     = alu_f_tb

WAVE_TOOL       = simvision
WAVE_DB_NAME    = waves

COV_TOOL        = imc

REGR_TOOL       = vmanager
VSIF_NAME       = rv0_core_rv32i
SERVER          = vbox
PORT            = 8080

SIM_TOOL        = xrun
TOP_FILE        = $(PROJECT_DIR)/tb/$(TOP_TB_NAME).sv

ISA_CFG         = rv0_core_cfg_rv32i

PROBE_TCL      += probe.tcl

#XCEL_OPTIONS   += +UVM_VERBOSITY=$(VERBOSITY)
#XCEL_OPTIONS   += +UVM_TESTNAME=$(TEST_NAME)
#XCEL_OPTIONS   += -covfile $(PROJECT_DIR)/scripts/covfile
#XCEL_OPTIONS   += -svseed $(SEED)
#XCEL_OPTIONS   += -access rwc
#XCEL_OPTIONS   += -timescale 1ns/1ns
#XCEL_OPTIONS   += -v93
#XCEL_OPTIONS   += -64b
#XCEL_OPTIONS   += -licqueue
XCEL_OPTIONS	+= -access +rwc
XCEL_OPTIONS   += -input $(PROJECT_DIR)/scripts/probe.tcl
#XCEL_OPTIONS   += -f $(PROJECT_DIR)/scripts/cfg/$(ISA_CFG)
#XCEL_OPTIONS   += -f $(BASE_DIR)/ip/utils/uvc_files
#XCEL_OPTIONS   += -f $(PROJECT_DIR)/scripts/tb_files
XCEL_OPTIONS   += -f $(PROJECT_DIR)/scripts/rtl_files
XCEL_OPTIONS   += $(TOP_FILE)

COV_OPTIONS    += -coverage all
COV_OPTIONS    += -covoverwrite

DBG_OPTIONS    += -linedebug
DBG_OPTIONS    += -uvmlinedebug

VMGR_OPTIONS   += -6_bit_color
VMGR_OPTIONS   += -dark
VMGR_OPTIONS   += -nostdout
VMGR_OPTIONS   += -server $(SERVER):$(PORT)

export PROJECT_NAME
export BASE_DIR
export PROJECT_DIR
export WORK_DIR
export IP_DIR
export TOP_TB_NAME

.PHONY:

run_gui:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(XCEL_OPTIONS) -gui;

run_batch:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(XCEL_OPTIONS) $(COV_OPTIONS) $(DBG_OPTIONS) -run;

regr_gui:
	@mkdir -p $(WORK_DIR)/regr; \
	 cd       $(WORK_DIR)/regr; \
	$(REGR_TOOL) $(VMGR_OPTIONS) -launch $(PROJECT_DIR)/scripts/vsif/$(VSIF_NAME).vsif

regr_batch:
	@mkdir -p $(WORK_DIR)/regr; \
	 cd       $(WORK_DIR)/regr; \
	$(REGR_TOOL) $(VMGR_OPTIONS) -execcmd "launch $(PROJECT_DIR)/scripts/vsif/$(VSIF_NAME).vsif"

load_wave:
	@cd $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
    $(WAVE_TOOL) $(WAVE_DB_NAME).shm

load_cov:
	@cd $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(COV_TOOL) -load cov_work/scope/test_sv$(SEED)

vmanager:
	@mkdir -p $(WORK_DIR)/vmgr; \
	 cd       $(WORK_DIR)/vmgr; \
	$(REGR_TOOL) $(VMGR_OPTIONS)

clean:
	@rm -rf $(WORK_DIR)/$(TEST_NAME)_$(SEED)

clean_regr:
	@rm -rf $(WORK_DIR)/regr

clean_all:
	@rm -rf $(WORK_DIR)

elaborate:
	$(SIM_TOOL) $(XCEL_OPTIONS) $(COV_OPTIONS) -elaborate -xmlibdirpath $(COMPILEDB)

reinvoke:
	$(SIM_TOOL) $(XCEL_OPTIONS) $(COV_OPTIONS) -R -xmlibdirpath $(COMPILEDB) -run
