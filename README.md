# Solution to the MATLAB & Simulink Challenge Project
## Improve the Accuracy of Satellite Navigation Systems

**Program:** https://github.com/mathworks/MATLAB-Simulink-Challenge-Project-Hub

**Project Description:** https://github.com/mathworks/MATLAB-Simulink-Challenge-Project-Hub/blob/main/projects/Improve%20the%20Accuracy%20of%20Satellite%20Navigation%20Systems/README.md

---

# BeiDou GF(64) Non-Binary LDPC Communication System

A complete MATLAB implementation of a **BeiDou B-CNAV2 compliant Non-Binary LDPC communication system** over **GF(64)**. The project implements the entire digital communication chain, from navigation message generation and LDPC encoding to AWGN transmission and iterative decoding using the **Extended Min-Sum (EMS)** algorithm.

The implementation closely follows the BeiDou B-CNAV2 Interface Control Document (ICD) while emphasizing algorithmic clarity and educational value through explicit Galois Field arithmetic, parity-check matrix operations, and iterative belief propagation.

---

# Features

- Complete end-to-end BeiDou B-CNAV2 communication chain
- GF(64) arithmetic using precomputed lookup tables
- Matrix-based Non-Binary LDPC encoder
- Extended Min-Sum (EMS) decoder with configurable Top-M truncation
- Tanner graph message passing
- Soft-decision decoding using Log-Likelihood Ratios (LLRs)
- Binary Phase Shift Keying (BPSK) modulation
- AWGN channel simulation
- BER and FER performance evaluation
- Automated SNR sweep for waterfall curve generation

---

# System Architecture

```
Navigation Message
        │
        ▼
 GF(64) Symbol Mapping
        │
        ▼
 Non-Binary LDPC Encoder
        │
        ▼
 BPSK Modulator
        │
        ▼
     AWGN Channel
        │
        ▼
 Soft LLR Generation
        │
        ▼
 EMS LDPC Decoder
        │
        ▼
Decoded Navigation Message
```

---

# Project Structure

```
NBLDPC/
│
├── main.m                  # Run a single communication simulation
├── ber_sweep.m             # BER/FER simulation over multiple SNR values
├── BER_results.mat
├── ber_plot.pdf
│
└── src/
    ├── buildGF.m
    ├── buildParityCheckMatrix.m
    ├── generateNavigationMessage.m
    ├── ldpcencodegf64.m
    ├── channel_awgn.m
    ├── llr2gf64.m
    ├── ldpcdecodegf64.m
    ├── ldpcdecodegf64_ems.m
    ├── ems_combine_messages.m
    ├── ems_truncate.m
    ├── runSimulation.m
    └── ...
```

---

# How It Works

## Transmitter

- Generates a BeiDou navigation message
- Converts binary data into GF(64) symbols
- Encodes the message using the Non-Binary LDPC parity-check matrix
- Converts the encoded symbols back into bits
- Modulates using BPSK

---

## Channel

The encoded signal is transmitted through an **Additive White Gaussian Noise (AWGN)** channel.

Noise level is controlled using the desired **Eb/N₀/SNR** during simulation.

---

## Receiver

The receiver performs:

1. Soft-decision demodulation
2. LLR computation
3. LLR-to-GF(64) conversion
4. Iterative EMS decoding
5. Syndrome verification
6. Bit reconstruction
7. BER/FER calculation

The EMS decoder reduces computational complexity by retaining only the **Top-M** most reliable symbol candidates during check-node processing.

---

# Running the Project

## Requirements

- MATLAB R2024b or newer (recommended)
- Communications Toolbox

---

## Run a Single Simulation

```matlab
main
```

The script automatically

- Loads GF(64) lookup tables
- Builds the parity-check matrix
- Generates a navigation frame
- Encodes the message
- Simulates transmission
- Decodes using EMS
- Displays BER, decoder status, and iteration count

---

## Generate BER Curve

```matlab
ber_sweep
```

This performs an automatic SNR sweep and computes

- Bit Error Rate (BER)
- Frame Error Rate (FER)

The generated performance curve is saved as:

```
ber_plot.pdf
```

---

# Example Output

```
=======================================
 Non-Binary LDPC Demonstration
=======================================

Decoder    : EMS
Top-M      : 16
BER        : 0.000e+00
Success    : 1
Iterations : 7
```

---

# Key Algorithms

- GF(64) finite field arithmetic
- Matrix-based LDPC encoding
- Tanner graph belief propagation
- Extended Min-Sum (EMS) decoding
- Check-node message truncation
- Variable-node message updates
- Syndrome-based early stopping

---

# Performance

The implementation supports configurable

- Decoder iterations
- Top-M parameter
- SNR
- Message length

The BER/FER performance can be evaluated across different noise conditions using the provided simulation scripts.

---

# References

1. **BeiDou Navigation Satellite System Signal In Space Interface Control Document (B1C & B2a Open Service Signals, Test Version, August 2017)**

2. Declercq, D., & Fossorier, M. (2007). *Decoding Algorithms for Non-Binary LDPC Codes over GF(q).* IEEE Transactions on Communications.

3. Davey, M. C., & MacKay, D. J. C. (1998). *Low Density Parity Check Codes over GF(q).*

---

# License

This project is released under the **MIT License**.
