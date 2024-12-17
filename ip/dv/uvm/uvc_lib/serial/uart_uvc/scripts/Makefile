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
# Date: 14.10.2024.
# Desc:
#
####################################################################################################
# Change History
# -------------------------------------------------------------------------------------------------
# Date         Author  Description
# -------------------------------------------------------------------------------------------------
#
####################################################################################################

PROJECT_NAME    = uart_uvc

IP_BASE_DIR     = $(HOME)/Projects/ip
PROJECT_DIR     = $(IP_BASE_DIR)/dv/uvm/uvc_lib/uart_uvc
WORK_DIR        = $(IP_BASE_DIR)/work/uvc_lib/uart_uvc

TEST_NAME       = test_$(PROJECT_NAME)_example
SEED            = 1
VERBOSITY       = UVM_LOW
TOP_TB_NAME     = $(PROJECT_NAME)_example_tb_top
TCL_NAME        = $(PROJECT_NAME)_probe

WAVE_TOOL       = simvision
WAVE_DB_NAME    = default

COV_TOOL        = imc

REGR_TOOL       = vmanager
VSIF_NAME       = tests
SERVER          = master
PORT            = 8080

SIM_TOOL        = xrun
TOP_FILE        = $(PROJECT_DIR)/example/tb/$(TOP_TB_NAME).sv

OPTIONS        += +UVM_VERBOSITY=$(VERBOSITY)
OPTIONS        += +UVM_TESTNAME=$(TEST_NAME)
OPTIONS        += -covfile $(PROJECT_DIR)/scripts/covfile
OPTIONS        += -svseed $(SEED)
OPTIONS        += -access rwc
OPTIONS        += -timescale 1ns/1ns
OPTIONS        += -v93
OPTIONS        += -64b
OPTIONS        += -licqueue
OPTIONS        += -f $(PROJECT_DIR)/scripts/tb_files
OPTIONS        += $(TOP_FILE)

COV_OPTIONS    += -coverage all
COV_OPTIONS    += -covoverwrite

DBG_OPTIONS    += -linedebug
DBG_OPTIONS    += -uvmlinedebug

export PROJECT_NAME
export IP_BASE_DIR
export PROJECT_DIR

.PHONY:

run_gui:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) $(DBG_OPTIONS) -gui $(RUN_TCL);

run_batch:
	@mkdir -p $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	 cd       $(WORK_DIR)/$(TEST_NAME)_$(SEED); \
	$(SIM_TOOL) $(OPTIONS) $(COV_OPTIONS) $(DBG_OPTIONS) $(RUN_TCL);

clean:
	@rm -rf $(WORK_DIR)
