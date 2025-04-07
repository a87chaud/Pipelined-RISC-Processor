# 5-Stage Pipelined RISC-V Processor

## Overview
This repository contains the Verilog implementation of a 5-stage pipelined processor based on the RISC-V instruction set architecture (ISA). The design follows a modular approach, progressing from a single-cycle datapath to a fully pipelined implementation.

## Features
Instruction Memory: Implements a memory module for storing and retrieving instructions.
Decode Stage: Parses instructions and prepares operands for execution.
Register File and Execute Stage: Handles register operations and arithmetic/logic computations.
Memory and Writeback Stages: Includes memory access and final result storage.
Pipelining: Optimizes execution with forwarding, bypassing, and stalling mechanisms.

├── src/
│   ├── instruction_memory.v    # Instruction memory module
│   ├── decode_stage.v          # Decode stage logic
│   ├── register_file.v         # Register file implementation
│   ├── execute_stage.v         # Execute stage logic
│   ├── memory_stage.v          # Memory access logic
│   ├── writeback_stage.v       # Writeback stage logic
│   ├── full_datapath.v         # Complete single-cycle datapath
│   ├── pipeline.v              # Pipelined processor implementation
└── docs/
    ├── architecture_diagram.pdf  # High-level processor architecture diagram
    ├── module_specs.md           # Detailed specifications for each module
