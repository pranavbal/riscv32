# 5-Stage Pipelined RV32I Processor with Verification and FPGA Implementation

## Overview

This project implements a 32-bit RV32I processor with a five-stage pipeline in SystemVerilog, together with a self-checking, class-based verification environment and synthesis and implementation results for a Xilinx Artix-7 FPGA (xc7a100tcsg324-1, as on the Nexys A7-100T). The design was simulated in Vivado XSim and taken through synthesis and implementation in Vivado 2025.2. It has not been programmed onto hardware.

## Microarchitecture

The pipeline is divided into instruction fetch (IF), instruction decode (ID), execute (EX), memory access (MEM), and write-back (WB), with a register between each pair of stages. Hazards are handled as follows:

- **Data hazards:** operands are forwarded to EX from the EX/MEM and MEM/WB registers.
- **Load-use hazards:** a stall unit holds the pipeline for a cycle when an instruction in ID depends on a load in EX.
- **Control hazards:** when a branch or jump redirects the PC, the instructions fetched behind it are flushed.

Branch prediction uses a 2-bit counter predictor and a 64-entry direct-mapped branch target buffer (BTB), indexed by `pc[7:2]` and tagged with `pc[31:8]`. Instruction memory is written through a dedicated port (`we`, `waddr`, `wdata`), which the testbench uses to load each program.

## Verification Methodology

The testbench follows the layering of UVM (transaction, sequencer, driver, monitor, agent, scoreboard) but is implemented as plain SystemVerilog classes, without the UVM library.

For each seed, a constrained-random generator produces an instruction stream that covers every RV32I instruction format. A golden reference model executes the same program and predicts each register write. The scoreboard compares the processor's write-back stream against these predictions in order, and at the end of each test the data memory is compared word by word against the model.

Seven directed tests cover situations that random streams reach only rarely: back-to-back load-use stalls, a store followed by a load from the same address, partial stores with sign and zero extension, shifts by 0 and 31, signed and unsigned boundary values, a branch as the final instruction, nested loops, and two branches that alias to one BTB entry.

Functional coverage has three groups: instruction kinds, 15 detail items (opcode variants, branch direction, memory base and offset, and others), and 6 processor-level items (forwarding paths, load-use stalls, flush causes, and predicted versus actual branch outcomes). Coverage holes found during development, such as branch operand equality and predictor training, were closed by adding constraints to the stimulus generator and not by relaxing the coverage goals.

| Check | Result |
|---|---|
| Random regression | 100 of 100 seeds pass (300 instructions each) |
| Directed tests | 7 of 7 pass |
| Instruction coverage | 100% |
| Detail coverage | 100% |
| Processor hazard and predictor coverage | 100% |

Coverage is collected per simulation run and is not merged across seeds, so the 100% figures are for seed 1. The regression criterion is that every one of the 100 seeds passes.

## Synthesis and Implementation

Synthesis and implementation were run out of context (the processor alone, without pin assignments) in Vivado 2025.2 with a 15 ns clock constraint (66.7 MHz).

| Metric | Result |
|---|---|
| Slice LUTs | 2,489 (3.93%) |
| Slice registers | 1,701 (1.34%) |
| Block RAM | 1 tile (0.74%) |
| DSP slices | 0 |
| Worst setup slack at 15 ns | +0.775 ns (all constraints met) |
| Worst hold slack | +0.126 ns |

The 1024 x 32 data memory is implemented in LUT RAM. Timing is reported for the processor alone with an ideal clock.

The design meets timing at 66.7 MHz. Across four implementation runs with different clock targets, the slowest path measured between 13.4 and 14.2 ns, so the maximum clock frequency is estimated at about 70 MHz.

The critical path begins at the forwarding select, passes through the ALU comparison to `branch_taken`, and ends at the reset input of the ID/EX pipeline registers (the flush). Roughly 78% of its delay is routing on high-fanout nets, and only 22% is logic. Flushing only the control fields instead of the whole stage should reduce that fanout. This change has not been implemented.

## Repository Structure

| Path | Contents |
|---|---|
| `rtl/` | processor RTL |
| `testbench/` | top-level testbench |
| `verification/` | sequencer, agent, driver, monitor, scoreboard, golden model, coverage |
| `constraints/` | `cpu_pipeline.xdc`, the clock constraint |
| `docs/` | utilization and timing reports |
| `cpu_project1/` | Vivado project and regression scripts |
| `program.hex` | default instruction memory image |

## Reproducing the Results

Vivado 2025.2 is required. XSim runs the simulations, and synthesis and implementation target the xc7a100t.

1. Open `cpu_project1/cpu_project1.xpr` and run a behavioral simulation.
2. Select the test with plusargs: `+SEED=<n>` and `+N=<count>` for a random program, or `+TEST=<1-7>` for a directed test.
3. In the Vivado Tcl console, `source cpu_project1/regress.tcl` runs the 100-seed regression and `source cpu_project1/regress_directed.tcl` runs the directed tests.