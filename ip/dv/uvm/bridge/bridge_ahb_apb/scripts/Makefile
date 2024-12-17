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
# Date: 02.10.2024.
# Desc:
#
####################################################################################################
# Change History
# -------------------------------------------------------------------------------------------------
# Date         Author  Description
# -------------------------------------------------------------------------------------------------
#
####################################################################################################

PROJECT_NAME    = bridge_ahb_apb

BASE_DIR        = $(HOME)/Projects/ip
PROJECT_DIR     = $(BASE_DIR)/dv/uvm/bridge/bridge_ahb_apb
WORK_DIR        = $(BASE_DIR)/work/bridge/bridge_ahb_apb

TEST_NAME       = test_$(PROJECT_NAME)_base
SEED            = 0
VERBOSITY       = UVM_LOW
TOP_TB_NAME     = $(PROJECT_NAME)_tb_top
TCL_NAME        = $(PROJECT_NAME)_probe

WAVE_TOOL       = simvision
WAVE_DB_NAME    = default

COV_TOOL        = imc

REGR_TOOL       = vmanager
VSIF_NAME       = $(PROJECT_NAME)_tests
SERVER          = master
PORT            = 8080

SIM_TOOL        = xrun
TOP_FILE        = $(PROJECT_DIR)/tb/$(TOP_TB_NAME).sv

OPTIONS        += +UVM_VERBOSITY=$(VERBOSITY)
OPTIONS        += +UVM_TESTNAME=$(TEST_NAME)
OPTIONS        += -covfile $(PROJECT_DIR)/scripts/covfile
OPTIONS        += -svseed $(SEED)
OPTIONS        += -access rwc
OPTIONS        += -timescale 1ns/1ns
OPTIONS        += -v93
OPTIONS        += -64b
OPTIONS        += -licqueue
OPTIONS        += -f $(BASE_DIR)/utils/uvc_files
OPTIONS        += -f $(PROJECT_DIR)/scripts/tb_files
OPTIONS        += -f $(PROJECT_DIR)/scripts/rtl_files
OPTIONS        += $(TOP_FILE)

COV_OPTIONS    += -coverage all
COV_OPTIONS    += -covoverwrite

DBG_OPTIONS    += -linedebug
DBG_OPTIONS    += -uvmlinedebug

export PROJECT_NAME
export BASE_DIR
export PROJECT_DIR
export WORK_DIR

.PHONY:

run_gui:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) $(DBG_OPTIONS) -gui $(WAVEFORM_TCL);

run_batch:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) $(DBG_OPTIONS);

regr_gui:
	@mkdir -p $(WORK_DIR)/regr; \
	 cd       $(WORK_DIR)/regr; \
	 $(REGR_TOOL) -server $(SERVER):$(PORT) -launch $(PROJECT_DIR)/scripts/$(VSIF_NAME).vsif

regr_batch:
	@mkdir -p $(WORK_DIR)/regr; \
	 cd       $(WORK_DIR)/regr; \
	 $(REGR_TOOL) -server $(SERVER):$(PORT) -execcmd "launch $(PROJECT_DIR)/scripts/$(VSIF_NAME).vsif"

load_wave:
	@cd $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
     $(WAVE_TOOL) $(WAVE_DB_NAME).shm

load_cov:
	@cd $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 $(COV_TOOL) -load cov_work/scope/test_sv$(SEED)

vmanager:
	@$(REGR_TOOL) -server $(SERVER):$(PORT)

clean:
	@rm -rf $(WORK_DIR)/$(TEST_NAME)_$(SEED)

clean_regr:
	@rm -rf $(WORK_DIR)/regr

clean_all:
	@rm -rf $(WORK_DIR)

elaborate:
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) -elaborate -xmlibdirpath $(COMPILEDB)

reinvoke:
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) -R -xmlibdirpath $(COMPILEDB)
