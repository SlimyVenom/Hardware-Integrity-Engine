# FPGA Hardware Integrity and SECDED Error-Correction Engine

## Overview

This project implements a modular hardware data-integrity engine in Verilog HDL for the Digilent Basys 3 FPGA board. It combines an 8-bit Hamming-distance monitor with a Single Error Correction, Double Error Detection (SECDED) encoder and decoder.

The system accepts a 4-bit data value and an 8-bit error mask. The encoder generates an 8-bit SECDED codeword, and the error mask introduces simulated bit flips into that codeword. The decoder then analyzes the received codeword, corrects supported single-bit errors, and detects double-bit errors.

The design provides:

- **SECDED encoding:** Converts four data bits into an eight-bit codeword containing Hamming parity bits and an overall parity bit.
- **Error injection:** XORs a programmable eight-bit error mask with the encoded codeword.
- **Error classification:** Uses the syndrome and overall parity to distinguish no-error, single-bit-error, and double-bit-error cases.
- **Single-bit correction:** Corrects a single flipped bit in the received codeword.
- **Double-bit detection:** Flags detected double-bit errors and marks the decoded data as invalid.
- **Hamming-distance monitoring:** Counts the number of differing bits between the transmitted and received codewords.
- **Hardware visualization:** Displays the input data, decoder output, syndrome, and error weight on the Basys 3 seven-segment display.

The design is a hardware SECDED and integrity-monitoring primitive. It is not a complete cryptographic or authentication system.

## Architecture

The design is organized into reusable Verilog modules, with `secded_wrapper` as the top-level module.

### 1. Full Adder

The `full_adder` module accepts three one-bit inputs, `a`, `b`, and `cin`, and produces `sum` and `cout`.

The sum is computed using XOR operations. The carry output is asserted when at least two of the three inputs are `1`.

### 2. Population Counters

The population-count logic is implemented hierarchically.

- `counter_2bit` counts the number of set bits in a two-bit input.
- `counter_4bit` combines two two-bit counters and the required addition logic to count set bits across four input bits.
- `counter_8bit` combines two four-bit counters to count the set bits in an eight-bit input.

The eight-bit counter is used to calculate the Hamming distance between the transmitted and received codewords.

### 3. Comparators

The design contains two comparator modules.

- `comparator_8bit` determines whether two eight-bit values are equal.
- `comparator_4bit` compares the calculated Hamming distance with a four-bit threshold and determines whether the distance is less than or equal to that threshold.

These modules provide the comparison logic used by the Hamming-distance monitor.

### 4. SECDED Encoder

The `secded_encoder` module converts four data bits into an eight-bit extended Hamming codeword.

The codeword contains three Hamming parity bits, four data bits, and one overall parity bit. The parity equations are arranged so that the first seven bits form a Hamming code and the eighth bit provides even overall parity.

The resulting codeword is passed to the error-injection stage.

### 5. Error Injection and Hamming-Distance Monitoring

The `secded_system` module XORs the encoded codeword with the eight-bit `error_mask`:

`received_codeword = transmitted_codeword XOR error_mask`

A zero bit in the mask leaves the corresponding transmitted bit unchanged. A one bit flips that bit.

The `hamming_distance8` module compares the transmitted and received codewords. It calculates the XOR difference, counts the differing bits, checks equality, and compares the error distance with a threshold of one.

This monitor reports the number of injected bit errors independently of the SECDED decoder's error classification.

### 6. SECDED Decoder

The `secded_decoder` module analyzes the received eight-bit codeword using two values:

- **Syndrome:** The three-bit result of the Hamming parity checks. It identifies a candidate bit position when the parity pattern indicates a single-bit error.
- **Overall parity:** The XOR of all eight received bits, used alongside the syndrome to distinguish error classes.

The decoder uses the syndrome and overall parity to classify the received codeword.

| Syndrome | Overall parity | Classification |
|---|---|---|
| Zero | Even parity | No error detected |
| Nonzero | Odd parity | Single-bit error in positions 1–7 |
| Zero | Odd parity | Single-bit error in the overall parity bit |
| Nonzero | Even parity | Double-bit error detected |

For a classified single-bit error, the decoder generates a correction mask and XORs it with the received codeword. The four original data bits are then extracted from the corrected codeword.

For a detected double-bit error, `double_error_detected` is asserted and `data_valid` is deasserted.

SECDED guarantees correction of a single-bit error and detection of a double-bit error under its standard assumptions. It does not guarantee correct classification of arbitrary errors involving three or more flipped bits; some higher-order patterns can be misclassified.

### 7. System Integration

The `secded_system` module connects the encoder, error-injection stage, Hamming-distance monitor, and decoder.

Its principal data path is:

1. Accept four input data bits.
2. Encode them into an eight-bit SECDED codeword.
3. Apply the eight-bit error mask.
4. Calculate the Hamming distance between the transmitted and received codewords.
5. Decode the received codeword.
6. Produce the corrected codeword, decoded data, syndrome, error classification flags, and data-valid status.

The SECDED datapath is combinational. The sequential logic required for display refresh is contained in the display controller.

### 8. Top-Level Wrapper

The `secded_wrapper` module connects the internal SECDED system to the Basys 3 board interface.

The wrapper maps switches to the input data and error mask, routes the corrected codeword and status flags to LEDs, and connects the display controller to the four-digit seven-segment display.

The display presents four values:

- Input data
- Decoded output data, or a dash when the data is invalid
- Syndrome
- Error weight

The wrapper also ties the unused upper four LEDs to zero.

### 9. Display Controller

The `display_controller` module drives the Basys 3 four-digit seven-segment display.

It uses a refresh counter and an active-display selector to multiplex the four digits. The five-bit digit inputs support hexadecimal values and a dash indication for invalid decoded data.

The display controller contains the design's sequential state: a 17-bit refresh counter and a two-bit active-display selector. Digit selection, segment decoding, and anode control are implemented using combinational logic.

## FPGA Interface

The design targets the Digilent Basys 3 FPGA board and uses its 100 MHz clock.

### Inputs

| Interface | Purpose |
|---|---|
| `clk` | 100 MHz board clock |
| `SW[3:0]` | Four-bit input data |
| `SW[11:4]` | Eight-bit error-injection mask |
| `SW[15:12]` | Unused by the current wrapper |

### Outputs

| Interface | Purpose |
|---|---|
| `LED[7:0]` | Corrected codeword |
| `LED[8]` | No-error indication |
| `LED[9]` | Single-error-corrected indication |
| `LED[10]` | Double-error-detected indication |
| `LED[11]` | Decoded-data validity |
| `LED[15:12]` | Tied to zero |
| `an[3:0]` | Seven-segment digit anodes |
| `seg[6:0]` | Seven-segment outputs |
| `dp` | Decimal-point output |

The pin assignments are defined in `constraints/basys3.xdc`. The wrapper is the intended top module for synthesis and implementation.

## Verification

The SECDED wrapper testbench is designed to exercise the complete data and error-classification path.

For each of the 16 possible four-bit input values, it tests:

- One no-error case.
- All eight possible single-bit error positions.
- All 28 possible pairs of bit positions for double-bit errors.

This produces the following test space:

| Test class | Cases per input | Total cases |
|---|---:|---:|
| No error | 1 | 16 |
| Single-bit error | 8 | 128 |
| Double-bit error | 28 | 448 |
| **Total** | **37** | **592** |

The testbench uses a behavioral reference encoder and checks the corrected codeword and the decoder status flags. It expects the original codeword to be preserved when no error is injected, corrected after any single-bit error, and marked invalid when a double-bit error is detected.

The simulation should be considered verified only after the testbench completes with zero failures and reports `ALL WRAPPER TESTS PASSED`. The testbench does not exhaustively verify all possible error masks; its coverage is limited to no-error, single-bit-error, and double-bit-error cases.

## Synthesis Results

The reported synthesis results for the SECDED design are:

| Resource | Utilization | Available | Utilization |
|---|---:|---:|---:|
| Lookup tables (LUTs) | 44 | 20,800 | 0.21% |
| Flip-flops (FFs) | 19 | 41,600 | 0.05% |
| Block RAM (BRAM) | 0 | — | 0% |
| DSP slices | 0 | — | 0% |
| I/O | 41 | 106 | 38.68% |

The LUT and flip-flop percentages are specific to the target FPGA device and synthesis configuration.

### Flip-Flop Breakdown

All 19 reported flip-flops belong to the display controller:

| State element | Width |
|---|---:|
| Display refresh counter | 17 bits |
| Active-display selector | 2 bits |
| **Total** | **19 bits** |

The SECDED datapath itself is combinational and does not require additional state elements.

### Resource Interpretation

The design uses a small number of LUTs and flip-flops because its main datapath consists of Boolean logic, parity calculations, population counting, comparisons, and correction-mask logic.

No block RAM or DSP resources are reported. The I/O utilization is higher than the LUT and flip-flop percentages because the design connects to the board's switches, LEDs, clock, and seven-segment display.

These values describe the reported synthesis result; they should not be interpreted as a substitute for timing analysis or post-implementation resource reports.

## Hardware Demonstration

The project targets the Digilent Basys 3 FPGA board. The hardware interface allows the input data and error mask to be configured using switches, with the corrected codeword and decoder status displayed through LEDs. The input, output, syndrome, and error weight are presented on the seven-segment display.

A board photograph is useful as a visual record of the hardware setup, but the photograph alone does not establish that every error case has been verified. Simulation and implementation reports provide complementary evidence.

## Hardware Integrity and Security Relevance

The project demonstrates hardware error-control and integrity-monitoring techniques.

SECDED coding is useful in systems where data corruption must be detected and, for a single-bit error, corrected. The Hamming-distance monitor separately measures how many bits differ between the transmitted and received codewords.

Potential application areas include:

- Memory and data-path error-control concepts
- Bit-level data-integrity monitoring
- Fault injection and error-classification experiments
- Threshold-based comparison of binary responses
- Hardware systems that need to detect or correct limited bit corruption

The project does not implement a complete cryptographic protocol, physical unclonable function (PUF), or hardware authentication system. Those applications would require additional system-level design and security analysis.

## Project Artifacts

The repository contains:

- Verilog RTL modules under `src/`
- SECDED wrapper testbench under `simulation/`
- Simulation images under `simulation/images/`
- Basys 3 pin constraints under `constraints/`
- FPGA implementation artifacts under `bitstream/`
- Synthesis results, diagrams, and this technical report under `results/`

The README provides a shorter project overview and links to the detailed technical report.

## Project Status

The RTL has been extended from a Hamming-distance and threshold-comparison engine to an integrated SECDED encoding, error-injection, decoding, and monitoring system.

The remaining validation steps are to confirm that the current testbench passes in simulation, ensure the implementation and timing reports correspond to the current `secded_wrapper` top module, and keep the documented images and resource counts aligned with the generated artifacts.
