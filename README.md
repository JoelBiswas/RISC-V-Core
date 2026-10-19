# RISC-V-Core
32-bit RISC-V core implementing an RV32I instruction subset, with SystemVerilog RTL, directed and constrained-random verification, and a SKY130 synthesis and physical design flow.

## Overview
### About the Project
This repository contains the files for a 32-bit CPU core I designed based on a subset of the RISC-V ISA. I have went through the full RTL to DGS pipline, from digital design to design verification to physical design. The final chip has an area of about 800,000 microns squared, with a 2:1 aspect ratio (1,271.95 microns x 635.975 microns). The chip features a two 1024x32 SRAM macros (ISRAM and DSRAM), and 6,798 standard cells.

![CPU Tapeout Image](Docs/Images/CPUAfterHSOptimizations.PNG)

### Why I Built This
This project was made as part of the onboarding process for the Georgia Tech SiliconJackets club. Additionally, this project taught me the fundamental skills needed to enter the world of VLSI design: digital design, design verification, and physical design. This is I field that I have grown increasingly interested in recently, and I hope to create more complex designs in the future.

### My Contributions
As this project was done as part of the SiliconJackets onboarding process, some of the files in this repo were provided by them. These include
- SRAM Macro
- Some verification skeleton code
- Certain physical design config files
- Makefiles

All of the CPU RTL was written by me. Additionally, all directed tests, constained-random tests, and assertions were written by me.

## Project Status
This project is still actively being improved. I am currently working on adding instruction pipelining to increase the clock frequency at the expense of throughput in branching-heavy programs.

## CPU Architecture — Datapath diagram, instruction fetch, decode, ALU, register file, memory interfaces, and execution timing.
![CPU Architecture Image](<Docs/Images/CPU Architecture.png>)
TODO: Add System Architecture Diagram

## Supported Instructions — A table of implemented instructions and limitations.
The following Subset of the RISC-V ISA has been implemented

`addi` with a positive immediate: add immediate
`addi` with a negative immediate: subtract immediate
`add`: register-register add
`sub`: register-register subtract
`lw`: load word from data SRAM using an immediate offset
`sw`: store word to data SRAM using an immediate offset
`beq` against x0: branch if zero
`sll`: left logical shift
`srl`: right logical shift
`ebreak`: halt the CPU

## Verification — Testbench structure, reference model, scoreboard, assertions, directed tests, and constrained-random testing.
TODO

## Physical Design — Technology/library versions, synthesis, floorplanning, placement, CTS, routing, and DRC/LVS methodology.
TODO

## Results — Verified measurements: timing, area, utilization, power if measured, coverage, and layout screenshots. State the run conditions and distinguish targets from achieved results.
TODO

## Repository Structure
TODO

## Requirements and External Dependencies — Required tools, versions, licenses, and how authorized users provide the excluded SRAM and PDK files.
TODO

## Running the Project — Environment setup and commands for simulation, waveforms, coverage, and physical design.
TODO

## Known Limitations and Future Work — ISA limitations, outstanding bugs, and planned improvements.
TODO

## Attribution and Licensing
TODO