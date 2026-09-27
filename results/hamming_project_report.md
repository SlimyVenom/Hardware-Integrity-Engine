# FPGA Hardware Data Integrity & Bit-Error Detection Engine

## Overview

This project implements a modular 8-bit Hamming-distance and threshold-comparison engine in Verilog HDL and deploys it on a Digilent Basys 3 FPGA.

The design accepts an 8-bit reference value, an 8-bit received value, and a programmable 4-bit integrity threshold and produces:

- **Error pattern:** bitwise XOR of the reference and received values
- **Error error_distance:** number of `1` bits in the error pattern
- **Exact match:** whether the reference and received values are identical
- **Integrity valid:** whether the error error_distance is less than or equal to the supplied threshold

The RTL is organized hierarchically using reusable counters, comparators, a multiplexer, a display controller, and a top-level hardware integrity engine.

## Architecture

The design is divided into the following modules.

### 1. Full Adder

The full adder accepts three inputs, `a`, `b`, and `cin`, and produces `sum` and `cout`.

The sum is computed using XOR operations. The carry output is asserted when at least two of the three inputs are `1`.

### 2. 2-bit Counter

The 2-bit counter counts the number of `1`s in two input bits, `a` and `b`.

The output can therefore represent `0`, `1`, or `2`.

- The MSB is computed as `a XOR b`.
- The LSB is computed as `a AND b`.

### 3. 4-bit Counter

The 4-bit counter is constructed hierarchically from two 2-bit counters and full adders.

The four input bits are divided into two groups of two. Each 2-bit counter computes the number of set bits in its group, and the resulting counts are added using full adders.

### 4. 8-bit Counter

The 8-bit counter extends the same hierarchical approach.

Two 4-bit counters process the two halves of the 8-bit input, and their results are combined using full adders to obtain the total number of set bits.

This counter is used as the population-count stage of the Hamming-distance datapath.

### 5. 8-bit Comparator

The 8-bit comparator determines whether two 8-bit values are equal.

Each corresponding pair of bits is compared using XOR. The results are combined so that the final equality output is asserted only when no corresponding bits differ.

### 6. 4-bit Comparator

The 4-bit comparator compares the calculated Hamming error_distance against the supplied threshold.

It determines whether:

The comparison checks whether the error distance is less than or equal to the supplied threshold.

The comparison tracks equality and whether the error_distance is greater than the threshold, with the most significant differing bit determining the result.

### 7. Hamming-Distance Engine

The main combinational datapath combines the counter and comparator modules.

For input values `reference_data` and `received_data`:

For the two inputs, the error pattern is the bitwise XOR of `reference_data` and `received_data`. The error distance is the number of set bits in that error pattern, and `exact_match` is true when the two values are identical.

The error_distance is then compared with the programmable threshold:

The integrity status is valid when the calculated error distance is less than or equal to the supplied threshold.

### 8. 8-bit Multiplexer

The multiplexer accepts two 8-bit inputs and a select signal and forwards one of the inputs to its output.

It is used by the hardware integrity engine to select between the data input and the previously captured reference or received value.

### 9. Display Controller

The display controller drives the Basys 3 four-digit seven-segment display.

It rapidly switches between display digits using a refresh counter so that the multiplexed display appears steady to a human observer.

The controller contains the sequential logic required for digit refresh and active-display selection, along with the combinational digit and segment decoding logic.

### 10. Hardware Integrity Engine

The top-level hardware integrity engine integrates:

- reference and received data capture registers
- 8-bit multiplexers
- the Hamming-distance engine
- the display controller
- LED outputs
- seven-segment display outputs

The engine captures the reference and received 8-bit values into registers and uses the multiplexer select signal to control which value is captured.

The resulting error pattern, exact-match status, and integrity-valid status are routed to the LEDs, while the calculated error error_distance is displayed on the seven-segment display.

## Data Path

The central computation can be summarized as:

The main datapath takes inputs A and B, computes their bitwise XOR, counts the differing bits to obtain the error distance, and compares that value with the supplied threshold.

A separate equality comparator evaluates:

The equality check compares `reference_data` with `received_data`.

The hardware integrity engine adds the data-capture and display logic around this combinational datapath.

## FPGA Interface

The design is intended for the Digilent Basys 3 FPGA board.

### Inputs

| Interface | Purpose |
|---|---|
| `SW[7:0]` | 8-bit data value |
| `SW[8]` | Reference/received data select |
| `SW[12:9]` | 4-bit integrity threshold |
| `clk` | 100 MHz board clock |

### Outputs

| Interface | Purpose |
|---|---|
| `LED[7:0]` | Error pattern |
| `LED[14]` | Integrity-valid indication |
| `LED[15]` | Exact-match indication |
| Seven-segment display | Displays the computed result |
| Anodes / segment lines | Seven-segment display control |

The Basys 3 pin assignments are defined in the accompanying Xilinx Design Constraints (`.xdc`) file.

## Verification

The design was verified using a self-contained behavioral testbench.

The testbench uses an independent behavioral reference model to calculate the expected outputs and compare them against the Design Under Test (DUT).

### Exhaustive test space

There are:

The exhaustive test space contains 256 possible reference values, 256 possible received values, and 16 possible threshold values, giving a total of 1,048,576 test cases.

The testbench therefore evaluates every possible pair of 8-bit reference and received values for every possible 4-bit threshold.

A `10 ns` delay is introduced after each input assignment to allow the combinational logic to settle before checking the outputs.

For each test case, the reference model computes:

For each test case, the reference model computes the expected error pattern from the XOR of the reference and received values, counts the set bits to obtain the expected error distance, checks whether the two inputs match, and checks whether the error distance is within the threshold.

Any mismatch causes the testbench to print detailed error information including the input values, expected outputs, and actual DUT outputs.

After all test cases are completed, the testbench reports the total number of tests and detected errors and produces a pass/fail verdict before terminating with `$finish`.

## Synthesis Results

The synthesized implementation produced the following resource usage:

| Resource | Utilization |
|---|---:|
| LUTs | 36 |
| Flip-Flops | 35 |
| BRAMs | 0 |
| DSPs | 0 |
| I/O pins | 42 |
| LUT/FF utilization | < 1% |

### Flip-Flop breakdown

The 35 flip-flops are attributed to:

The 35 flip-flops consist of 8 for `reference_data`, 8 for `received_data`, 17 for the display refresh counter, and 2 for `active_display`, for a total of 35.

The design uses no block RAM or DSP resources, as the datapath consists of Boolean logic, adders, comparators, multiplexers, and display-control logic rather than memory or multiplication hardware.

## Synthesized Architecture

The synthesized design preserves the hierarchical organization of the RTL.

The implementation can be divided into three major regions:

1. **Data capture logic** — two multiplexer structures feeding the two 8-bit data registers.
2. **Hamming-distance datapath** — combinational logic implementing XOR, population counting, equality comparison, and threshold comparison.
3. **Display controller** — sequential refresh logic together with digit-selection, segment decoding, and anode-control logic.

The central Hamming-distance engine remains combinational, while the operand capture registers and display controller provide the sequential state required by the FPGA implementation.

The synthesis results reported no inferred latches or unconstrained-port warnings, and the reported resource counts correspond to the intended RTL structure.

## Hardware Demonstration

The completed design was synthesized and implemented on a Digilent Basys 3 FPGA board.

The hardware demonstration provides physical verification that the RTL design, FPGA constraints, synthesis/implementation flow, and board-level I/O operate together as intended.

## Hardware Security and Data-Integrity Relevance

The implemented circuit is a **Hamming-distance and threshold-comparison primitive**, rather than a complete cryptographic, authentication, or error-correcting-code system.

Its core operation is useful in systems that need to measure and bound bit-level deviations between two binary values.

Potential application areas include:

- bit-level data-integrity monitoring
- corrupted-data or packet-deviation detection
- threshold-based fault tolerance
- hardware-response similarity checking
- PUF-oriented response comparison
- hardware authentication pipelines

In a PUF-oriented system, for example, the Hamming-distance engine could be used as a hardware primitive for comparing a measured response against a reference response and determining whether the deviation falls within an acceptable threshold. The present project does **not** implement a PUF or an authentication protocol itself.

## Project Artifacts

The repository contains the RTL implementation, verification environment, FPGA constraints, implementation artifacts, and supporting documentation.

The original course-submission report has been replaced by this project-focused document so that the repository describes the engineering work directly rather than presenting it as a laboratory submission.

## Project Status

The hardware design and FPGA implementation are complete.

The repository is being organized as a reproducible portfolio artifact containing:

- modular Verilog RTL
- exhaustive simulation/testbench
- Basys 3 FPGA constraints
- generated bitstream
- synthesis and hardware results
- architectural documentation
