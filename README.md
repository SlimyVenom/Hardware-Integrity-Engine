# FPGA Hardware Integrity & SECDED Error-Correction Engine

A modular Verilog HDL implementation of a hardware data-integrity engine for the Digilent Basys 3 FPGA. The design combines an 8-bit Hamming-distance monitor with a Single Error Correction, Double Error Detection (SECDED) encoder and decoder.

The system encodes four data bits into an eight-bit codeword, injects configurable bit errors, and processes the received codeword to correct single-bit errors and detect double-bit errors.

![System Architecture](results/block-diagram.png)

## Overview

The design provides the following functionality:

- **SECDED encoding** — generates an eight-bit extended Hamming codeword from four input data bits.
- **Error injection** — flips selected codeword bits using an eight-bit error mask.
- **Error classification** — uses the syndrome and overall parity to classify no-error, single-bit-error, and double-bit-error cases.
- **Single-bit correction** — identifies and corrects a single flipped bit in the received codeword.
- **Double-bit detection** — flags detected double-bit errors and marks the decoded data as invalid.
- **Hamming-distance monitoring** — calculates the number of differing bits between the transmitted and received codewords.
- **Hardware visualization** — displays the input data, decoded output, syndrome, and error weight on the Basys 3 seven-segment display.

The SECDED datapath is combinational. The display controller contains the sequential logic required for multiplexed display refresh.

## Architecture

The design is organized into reusable Verilog modules, with `secded_wrapper` as the top-level module.

- **`secded_wrapper`** connects the internal design to the Basys 3 switches, LEDs, and seven-segment display.
- **`secded_system`** integrates encoding, error injection, Hamming-distance monitoring, and decoding.
- **`secded_encoder`** generates the eight-bit SECDED codeword from the four-bit input.
- **`secded_decoder`** calculates the syndrome and overall parity, classifies errors, corrects supported single-bit errors, and extracts the original data.
- **`hamming_distance8`** computes the XOR difference between the transmitted and received codewords, counts differing bits, checks equality, and compares the error distance against a threshold.
- **`counter_8bit`** implements population counting hierarchically using two `counter_4bit` modules. These are built from `counter_2bit` modules and `full_adder` logic.
- **`comparator_8bit`** and **`comparator_4bit`** implement equality and threshold-comparison logic.
- **`display_controller`** multiplexes the four seven-segment digits and supports hexadecimal values and a dash for invalid decoded data.

### Data path

The system processes each input as follows:

1. Four input bits are encoded into an eight-bit SECDED codeword.
2. The eight-bit error mask is XORed with the transmitted codeword to produce the received codeword.
3. The Hamming-distance monitor counts the differing bits between the transmitted and received codewords.
4. The decoder calculates the syndrome and overall parity to classify the error.
5. A single-bit error is corrected, while a detected double-bit error causes the decoded data to be marked invalid.
6. The corrected codeword, status flags, and diagnostic values are routed to the board outputs.

SECDED guarantees correction of single-bit errors and detection of double-bit errors under its standard assumptions. It does not guarantee correct classification of arbitrary errors involving three or more flipped bits.

## Hardware Interface

The design targets the **Digilent Basys 3** FPGA board and uses its 100 MHz clock.

### Inputs

| Interface | Function |
|---|---|
| `SW[3:0]` | Four-bit input data |
| `SW[11:4]` | Eight-bit error-injection mask |
| `SW[15:12]` | Unused by the current wrapper |
| `clk` | 100 MHz board clock |

### Outputs

| Interface | Function |
|---|---|
| `LED[7:0]` | Corrected codeword |
| `LED[8]` | No-error indication |
| `LED[9]` | Single-error-corrected indication |
| `LED[10]` | Double-error-detected indication |
| `LED[11]` | Decoded-data validity |
| `LED[15:12]` | Tied to zero |
| Seven-segment display | Input data, decoded output, syndrome, and error weight |
| Anodes and segment lines | Seven-segment display control |

The complete Basys 3 pin mapping is provided in [`constraints/basys3.xdc`](constraints/basys3.xdc).

## Verification

The SECDED wrapper testbench is designed to check the principal supported error cases across every possible four-bit input value.

For each of the 16 input datawords, it tests:

- One no-error case.
- All eight possible single-bit error positions.
- All 28 possible pairs of bit positions for double-bit errors.

This gives a total of 592 test cases:

| Test class | Total cases |
|---|---:|
| No error | 16 |
| Single-bit errors | 128 |
| Double-bit errors | 448 |
| **Total** | **592** |

The testbench uses a behavioral reference encoder and checks the corrected codeword and decoder status flags.

The testbench is located at [`simulation/testbench.v`](simulation/testbench.v). The simulation should be considered verified after it completes with zero failures and reports `ALL WRAPPER TESTS PASSED`.

A waveform image is maintained in [`simulation/images/waveform.png`](simulation/images/waveform.png). It should correspond to the current SECDED testbench once the updated simulation has been run and captured.

## FPGA Implementation

The design is intended for synthesis and implementation on the Digilent Basys 3 FPGA.

### Resource utilization

The reported synthesis results for the SECDED design are:

| Resource | Used | Available | Utilization |
|---|---:|---:|---:|
| LUTs | 44 | 20,800 | 0.21% |
| Flip-flops | 19 | 41,600 | 0.05% |
| I/O | 41 | 106 | 38.68% |
| BRAM | 0 | — | 0% |
| DSP | 0 | — | 0% |

All 19 reported flip-flops belong to the display controller: 17 bits for the refresh counter and two bits for the active-display selector. The SECDED datapath itself is combinational.

The implementation uses no block RAM or DSP resources. The reported LUT and flip-flop percentages are specific to the target FPGA and synthesis configuration.

The synthesis schematic and utilization screenshot are maintained in the repository's `simulation/images/` and `results/` directories, respectively.

## Hardware Demonstration

The project targets the Digilent Basys 3 FPGA board. Switches configure the input data and error mask, LEDs expose the corrected codeword and error-classification status, and the seven-segment display presents diagnostic values.

The board photograph in [`results/basys3-demo.jpeg`](results/basys3-demo.jpeg) provides a visual record of the hardware setup. Simulation and implementation results provide additional evidence beyond the photograph itself.

## Hardware Integrity and Security Relevance

The project demonstrates hardware error-control and integrity-monitoring techniques. SECDED coding is useful in systems that need to correct a single-bit error and detect a double-bit error, while the Hamming-distance monitor independently measures bit-level deviation.

Potential application areas include:

- Data-path and memory error-control concepts
- Bit-level data-integrity monitoring
- Fault-injection and error-classification experiments
- Threshold-based comparison of binary responses
- PUF-oriented response comparison

The project does **not** implement a complete cryptographic protocol, physical unclonable function (PUF), or hardware authentication system. Such applications require additional system-level design and security analysis.

## Repository Structure

```text
Hamming/
├── bitstream/
│   └── bitstream.bit
├── constraints/
│   └── basys3.xdc
├── results/
│   ├── basys3-demo.jpeg
│   ├── block-diagram.png
│   ├── hamming_project_report.md
│   └── Screenshot from 2026-10-12 14-41-48.png
├── simulation/
│   ├── images/
│   │   ├── Schematic-rtl.png
│   │   └── waveform.png
│   └── testbench.v
├── src/
│   ├── comparator_4bit.v
│   ├── comparator_8bit.v
│   ├── counter_2bit.v
│   ├── counter_4bit.v
│   ├── counter_8bit.v
│   ├── display_controller.v
│   ├── full_adder.v
│   ├── hamming_distance8.v
│   ├── secded_decoder.v
│   ├── secded_encoder.v
│   └── secded_system.v
│   └── secded_wrapper.v
└── README.md
```

## Documentation

The detailed technical report is available in [`results/hamming_project_report.md`](results/hamming_project_report.md). It describes the module-level architecture, SECDED behavior, hardware interface, verification strategy, synthesis results, and limitations.

## Project Status

The RTL has been extended from a Hamming-distance and threshold-comparison engine to an integrated SECDED encoding, error-injection, decoding, and monitoring system.

The current repository includes the RTL, Basys 3 constraints, testbench, implementation artifacts, and technical documentation. Simulation and implementation claims should be kept aligned with the latest verified results.
