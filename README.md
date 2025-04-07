# 5-Stage Pipelined RISC-V Processor


## Overview
This repository contains a Verilog implementation of a 5-stage pipelined RISC-V processor, developed using the synthesizable subset of Verilog at the register-transfer level (RTL). The design progresses from a single-cycle datapath to a fully pipelined implementation with hazard resolution.

## Features
- **Modular Design**: Five distinct pipeline stages (Fetch, Decode, Execute, Memory, Writeback)
- **RISC-V ISA Support**: Implements base integer instruction set (RV32I)
- **Hazard Resolution**: Forwarding, bypassing, and stalling mechanisms
- **Synthesizable Code**: Strict adherence to synthesizable Verilog subset

## Directory Structure

<img width="732" alt="Screenshot 2025-04-06 at 9 04 33 PM" src="https://github.com/user-attachments/assets/6a19a55d-f41e-44f8-abfc-91c613a6f0ce" />
