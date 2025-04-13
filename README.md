# 5-Stage Pipelined RISC-V Processor


## Overview
This repository contains a Verilog implementation of a 5-stage pipelined RISC-V processor, developed using the synthesizable subset of Verilog at the register-transfer level (RTL). The design progresses from a single-cycle datapath to a fully pipelined implementation with hazard resolution.

## Features
- **Modular Design**: Five distinct pipeline stages (Fetch, Decode, Execute, Memory, Writeback)
- **RISC-V ISA Support**: Implements base integer instruction set (RV32I)
- **Hazard Resolution**: Forwarding, bypassing, and stalling mechanisms
- **Synthesizable Code**: Strict adherence to synthesizable Verilog subset

## Branch Prediction Implementation
The processor includes a branch predictor using a local branch prediction  (`branch_predictor.v`) to reduce the branch penalty. This module uses a 2-bit saturating counter for each entry in a local history table.


## Directory Structure

