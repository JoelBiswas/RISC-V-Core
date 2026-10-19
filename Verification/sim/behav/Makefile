# Cadence Xcelium / SimVision / IMC flow

INCLUDE_FILE_NAME ?= member.include
TOP ?= cpu_tb_top
PYTHON ?= python3
IMC ?= imc

CURRENT_DIR := $(shell pwd)
WORKSPACE := $(CURRENT_DIR)/WORKSPACE

XRUN_FLAGS = -64bit -sv -linedebug -access +rwc \
             -timescale 1ns/10ps +define+SIM=1 +incdir+sym_links \
             -coverage all -licqueue -covoverwrite

SIM_PLUSARGS ?=
SEED ?= 1
LOGFILE ?= simulation.log
WAVE_PLUSARGS ?=
COV_TEST ?= member

.PHONY: help clean link xrun simvision coverage run_and_view

help:
	@echo "  make xrun [SEED=n]              run your CPU"
	@echo "  make simvision                   open the member-CPU waveform"
	@echo "  make coverage                    open the member coverage database"
	@echo "  make clean                       remove generated simulation files"

clean:
	@rm -rf $(WORKSPACE)

link:
	@mkdir -p $(WORKSPACE)/sym_links
	@rm -rf $(WORKSPACE)/sym_links/*
	@$(PYTHON) link_files.py $(INCLUDE_FILE_NAME)

xrun: link
	cd $(WORKSPACE) && \
	xrun $(XRUN_FLAGS) -svseed $(SEED) -f sym_links/sim_no_path.include \
	     -top $(TOP) -covtest $(COV_TEST) -logfile $(LOGFILE) \
	     +SEED_LABEL=$(SEED) $(WAVE_PLUSARGS) $(SIM_PLUSARGS)

simvision:
	cd $(WORKSPACE) && simvision waves.shm &


coverage:
	cd $(WORKSPACE) && $(IMC) -load cov_work/scope/$(COV_TEST) -load_refinement $(CURRENT_DIR)/exclusions.vRefine &

run_and_view: xrun simvision

.DEFAULT_GOAL := run_and_view
