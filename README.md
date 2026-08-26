# AES128-XHEEP

## AES-128 Encryption Accelerator

A synthesizable **AES-128 encryption accelerator** implemented in SystemVerilog, designed for eventual integration as a memory-mapped peripheral in the **X-HEEP RISC-V SoC**.

The project follows a modular RTL architecture where each AES transformation is implemented and verified independently before being integrated into the complete encryption core.

---

## Project Status

## Project Status

### Standalone AES-128 Core — Complete

- [x] AES S-box
- [x] SubBytes
- [x] ShiftRows
- [x] MixColumns
- [x] AddRoundKey
- [x] AES-128 Key Expansion
- [x] AES Normal Round
- [x] AES Final Round
- [x] Round Controller
- [x] Complete AES-128 Core
- [x] Standard AES-128 test-vector verification

### VLSI Implementation — Complete

- [x] RTL synthesis — SKY130HS
- [x] Static timing analysis — SKY130HS
- [x] RTL synthesis — Nangate45
- [x] Static timing analysis — Nangate45
- [x] OpenROAD physical design — SKY130HS
- [x] OpenROAD physical design — Nangate45
- [x] Final GDS generation — SKY130HS
- [x] Final GDS generation — Nangate45
- [x] Area analysis
- [x] Power analysis
- [x] Routing / physical-design DRC reports

### X-HEEP Integration — In Progress

- [ ] X-HEEP peripheral wrapper
- [ ] Memory-mapped register interface
- [ ] X-HEEP SoC integration
- [ ] C software driver
- [ ] Hardware/software verification
- [ ] Software vs hardware performance benchmark

---

# 1. AES-128 Overview

AES (Advanced Encryption Standard) is a symmetric block cipher standardized by NIST.

AES-128 operates on:

- **128-bit plaintext**
- **128-bit encryption key**
- **128-bit ciphertext**

AES-128 performs:

- 1 initial AddRoundKey operation
- 9 standard AES rounds
- 1 final AES round

Therefore, the encryption consists of **10 rounds**.

---

# 2. AES-128 Data Format

AES operates on a 128-bit block:

```text
128 bits = 16 bytes
```

Example plaintext:

```text
00112233445566778899AABBCCDDEEFF
```

The 16 bytes are:

```text
00 11 22 33 44 55 66 77
88 99 AA BB CC DD EE FF
```

The AES-128 key is also 128 bits:

```text
000102030405060708090A0B0C0D0E0F
```

---

# 3. AES Encryption Flow

The complete AES-128 encryption flow is:

```text
                 Plaintext
                     │
                     ▼
              AddRoundKey
                     │
                     ▼
              ┌─────────────┐
              │   Round 1   │
              └──────┬──────┘
                     │
                    ...
                     │
              ┌──────▼──────┐
              │   Round 9   │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │  Round 10   │
              │ Final Round │
              └──────┬──────┘
                     │
                     ▼
                Ciphertext
```

### Rounds 1–9

Each standard round performs:

```text
SubBytes
    ↓
ShiftRows
    ↓
MixColumns
    ↓
AddRoundKey
```

### Round 10

The final round performs:

```text
SubBytes
    ↓
ShiftRows
    ↓
AddRoundKey
```

**MixColumns is intentionally omitted from the final round.**

---

# 4. RTL Architecture

The project is divided into independent SystemVerilog modules.

```text
aes_core
│
├── round_controller
│
├── key_expansion
│   └── aes_sbox
│
├── add_round_key
│
├── aes_round
│   ├── sub_bytes
│   │   └── aes_sbox
│   ├── shift_rows
│   ├── mix_columns
│   └── add_round_key
│
└── aes_final_round
    ├── sub_bytes
    │   └── aes_sbox
    ├── shift_rows
    └── add_round_key
```

---

# 5. AES RTL Modules

## `aes_sbox.sv`

Implements the standard AES S-box.

The S-box maps an 8-bit input to an 8-bit output.

Example:

```text
Input  : 00
Output : 63

Input  : 53
Output : ED
```

The AES S-box is a standardized transformation and is not custom-designed for this project.

---

## `sub_bytes.sv`

Applies the AES S-box independently to all 16 bytes of the 128-bit state.

```text
128-bit state
      │
      ▼
┌─────────────────┐
│ 16 × AES S-box  │
└────────┬────────┘
         │
         ▼
128-bit state
```

---

## `shift_rows.sv`

Implements the AES ShiftRows permutation.

The AES state is arranged as four rows of four bytes.

```text
Row 0 → shift by 0
Row 1 → shift by 1
Row 2 → shift by 2
Row 3 → shift by 3
```

ShiftRows is purely a byte permutation and does not require arithmetic.

---

## `mix_columns.sv`

Implements the AES MixColumns transformation.

Each AES column contains four bytes.

The transformation uses arithmetic over:

```text
GF(2^8)
```

This is one of the main arithmetic blocks in the AES datapath.

---

## `add_round_key.sv`

Performs the AES AddRoundKey operation.

The operation is simply:

```text
state_out = state_in XOR round_key
```

---

## `key_expansion.sv`

Generates all 11 round keys required by AES-128.

```text
Round 0  → Key 0
Round 1  → Key 1
Round 2  → Key 2
...
Round 10 → Key 10
```

The key schedule uses:

- RotWord
- SubWord
- Rcon
- XOR operations

The AES S-box is reused for the SubWord operation.

---

## `aes_round.sv`

Implements a complete standard AES round.

```text
state_in
   │
   ▼
SubBytes
   │
   ▼
ShiftRows
   │
   ▼
MixColumns
   │
   ▼
AddRoundKey
   │
   ▼
state_out
```

This block is used for AES rounds **1 through 9**.

---

## `aes_final_round.sv`

Implements AES round 10.

```text
state_in
   │
   ▼
SubBytes
   │
   ▼
ShiftRows
   │
   ▼
AddRoundKey
   │
   ▼
state_out
```

Unlike the normal AES round, **MixColumns is not performed**.

---

## `round_controller.sv`

Controls the sequential encryption process.

```text
IDLE
  │
  │ start
  ▼
INIT
  │
  ▼
ROUND 1
  │
  ▼
ROUND 2
  │
  ▼
  ...
  │
  ▼
ROUND 9
  │
  ▼
ROUND 10
  │
  ▼
DONE
  │
  ▼
IDLE
```

Round numbering:

```text
Round 0  → Initial AddRoundKey
Rounds 1–9 → Normal AES rounds
Round 10 → Final AES round
```

---

# 6. AES Core

## `aes_core.sv`

`aes_core` is the top-level standalone AES encryption engine.

### Interface

```systemverilog
input  logic         clk;
input  logic         rst_n;
input  logic         start;

input  logic [127:0] plaintext;
input  logic [127:0] key;

output logic [127:0] ciphertext;
output logic         busy;
output logic         done;
```

### Operation

```text
plaintext
    │
    ▼
Initial AddRoundKey
    │
    ▼
AES Round 1
    │
    ▼
AES Round 2
    │
    ▼
...
    │
    ▼
AES Round 9
    │
    ▼
AES Final Round
    │
    ▼
ciphertext
```

---

# 7. Iterative Architecture

The current AES core uses an **iterative architecture**.

Only one physical `aes_round` datapath is instantiated and reused for rounds 1–9.

```text
             ┌─────────────┐
             │  aes_round  │
             └──────┬──────┘
                    │
                    ▼
              State Register
                    │
                    │ next clock
                    ▼
             ┌─────────────┐
             │  aes_round  │
             └──────┬──────┘
                    │
                    ▼
              State Register
                    │
                   ...
```

Therefore:

```text
Round 1 → same hardware
Round 2 → same hardware
Round 3 → same hardware
...
Round 9 → same hardware
```

### Advantage

Lower hardware area because the round datapath is reused.

### Trade-off

Higher encryption latency because multiple clock cycles are required for one AES block.

This area-vs-latency trade-off will be evaluated during the VLSI stage.

---

# 8. AES Core Interface

The standalone AES core accepts:

| Signal | Width | Direction | Description |
|---|---:|---|---|
| `clk` | 1 | Input | Clock |
| `rst_n` | 1 | Input | Active-low reset |
| `start` | 1 | Input | Start encryption |
| `plaintext` | 128 | Input | 128-bit plaintext |
| `key` | 128 | Input | 128-bit AES key |
| `ciphertext` | 128 | Output | 128-bit ciphertext |
| `busy` | 1 | Output | Encryption in progress |
| `done` | 1 | Output | Encryption complete |

---

# 9. Verification

Every major RTL block has an associated testbench.

```text
tb/
├── aes_sbox_tb.sv
├── sub_bytes_tb.sv
├── shift_rows_tb.sv
├── mix_columns_tb.sv
├── add_round_key_tb.sv
├── key_expansion_tb.sv
├── aes_round_tb.sv
├── aes_final_round_tb.sv
├── round_controller_tb.sv
└── aes_core_tb.sv
```

The complete AES core was verified using the standard AES-128 known-answer test vector.

---

# 10. AES-128 Known-Answer Test

### Plaintext

```text
00112233445566778899AABBCCDDEEFF
```

### Key

```text
000102030405060708090A0B0C0D0E0F
```

### Expected Ciphertext

```text
69C4E0D86A7B0430D8CDB78070B4C55A
```

### Verification Result

```text
AES_CORE PASS
```

The simulated ciphertext was:

```text
69C4E0D86A7B0430D8CDB78070B4C55A
```

which matches the expected result exactly.

---

# 11. Simulation

The project uses **Icarus Verilog** for RTL simulation.

Example:

```bash
iverilog -g2012 -o sim/aes_core_tb.out \
rtl/aes_sbox.sv \
rtl/sub_bytes.sv \
rtl/shift_rows.sv \
rtl/mix_columns.sv \
rtl/add_round_key.sv \
rtl/key_expansion.sv \
rtl/aes_round.sv \
rtl/aes_final_round.sv \
rtl/round_controller.sv \
rtl/aes_core.sv \
tb/aes_core_tb.sv
```

Run:

```bash
vvp sim/aes_core_tb.out
```

Expected result:

```text
AES_CORE PASS
```

---
# 12. VLSI Implementation

The standalone AES-128 core has been taken through synthesis, static timing analysis, and complete OpenROAD physical implementation using two standard-cell technologies:

- **SKY130HS**
- **Nangate45**

Both implementations were taken through synthesis, floorplanning, placement, clock-tree synthesis, routing, filler insertion, and final GDS generation.

## SKY130HS

| Metric | Result |
|---|---:|
| Standard-cell technology | **SKY130HS** |
| Target clock period | **10.00 ns** |
| Target frequency | **100 MHz** |
| Synthesized chip area | **117,781.3008 µm²** |
| Sequential area | **10,183.4064 µm² (8.65%)** |
| Post-route minimum clock period | **4.64 ns** |
| Post-route maximum frequency | **215.61 MHz** |
| Worst setup slack | **+5.36 ns** |
| Worst hold slack | **+0.19 ns** |
| WNS | **0.00 ns** |
| TNS | **0.00 ns** |
| Setup violations | **0** |
| Hold violations | **0** |
| Max slew violations | **0** |
| Max fanout violations | **0** |
| Max capacitance violations | **0** |
| Total reported power | **104 mW** |
| Internal power | **63.2 mW** |
| Switching power | **40.4 mW** |
| Leakage power | **0.996 µW** |
| Final GDS | `physical_design/sky130hs/openroad/gds/` |

The SKY130HS implementation is timing-clean at the 10 ns target clock period, with no setup, hold, slew, fanout, or capacitance violations in the final OpenROAD report. The post-route analysis reports a minimum achievable clock period of **4.64 ns**, corresponding to a maximum frequency of **215.61 MHz**. :contentReference[oaicite:2]{index=2}

### SKY130HS Power Breakdown

| Power Group | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| Sequential | 3.65 mW | 5.48 mW | 0.160 µW | 9.13 mW |
| Combinational | 58.7 mW | 34.1 mW | 0.825 µW | 92.8 mW |
| Clock | 0.927 mW | 0.816 mW | 0.0108 µW | 1.74 mW |
| **Total** | **63.2 mW** | **40.4 mW** | **0.996 µW** | **104 mW** |

The combinational logic accounts for the majority of the reported power at approximately **89.5%**, followed by sequential logic at **8.8%** and clock circuitry at **1.7%**. :contentReference[oaicite:3]{index=3}

---

## Nangate45

| Metric | Result |
|---|---:|
| Standard-cell technology | **Nangate45** |
| Target clock period | **10.00 ns** |
| Target frequency | **100 MHz** |
| Synthesized chip area | **16,015.3280 µm²** |
| Sequential area | **1,473.6400 µm² (9.20%)** |
| Post-route minimum clock period | **1.97 ns** |
| Post-route maximum frequency | **507.92 MHz** |
| Worst setup slack | **+8.03 ns** |
| Worst hold slack | **0.00 ns (violated)** |
| WNS | **0.00 ns** |
| TNS | **0.00 ns** |
| Setup violations | **0** |
| Hold violations | **9** |
| Max slew violations | **0** |
| Max fanout violations | **0** |
| Max capacitance violations | **3** |
| Total reported power | **13.5 mW** |
| Internal power | **6.47 mW** |
| Switching power | **6.62 mW** |
| Leakage power | **0.401 mW** |
| Final GDS | `physical_design/nangate45/openroad/gds/` |

The Nangate45 implementation completed the full OpenROAD physical-design flow and provides substantially greater setup-timing headroom than SKY130HS. The final report gives a minimum achievable clock period of **1.97 ns**, corresponding to a maximum frequency of **507.92 MHz**. However, the implementation retains **9 hold violations** and **3 maximum-capacitance violations**. :contentReference[oaicite:4]{index=4}

### Nangate45 Power Breakdown

| Power Group | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| Sequential | 0.427 mW | 0.600 mW | 0.0274 mW | 1.05 mW |
| Combinational | 5.99 mW | 5.95 mW | 0.371 mW | 12.3 mW |
| Clock | 0.0532 mW | 0.0761 mW | 0.00188 mW | 0.131 mW |
| **Total** | **6.47 mW** | **6.62 mW** | **0.401 mW** | **13.5 mW** |

Combinational logic accounts for approximately **91.2%** of the reported power, sequential logic approximately **7.8%**, and clock circuitry approximately **1.0%**. :contentReference[oaicite:5]{index=5}

---

## OpenROAD Physical Design Flow

Both technologies were taken through the complete physical-design flow:

1. **RTL**
2. ↓
3. **Synthesis**
4. ↓
5. **Floorplanning**
6. ↓
7. **Tapcell / Power Distribution Network**
8. ↓
9. **Global Placement**
10. ↓
11. **Detailed Placement**
12. ↓
13. **Clock Tree Synthesis**
14. ↓
15. **Global Routing**
16. ↓
17. **Detailed Routing**
18. ↓
19. **Filler Cell Insertion**
20. ↓
21. **Final Physical Verification**
22. ↓
23. **DEF / SPEF / Post-route Verilog**
24. ↓
25. **Final GDSII**

The final physical-design outputs include:

- **GDSII** — final layout database
- **DEF** — final physical design
- **SPEF** — extracted parasitics
- **Post-route Verilog** — final netlist
- **OpenROAD database** — final implementation database
- **Timing reports**
- **Power reports**
- **Routing DRC reports**
  
# 13. Proposed X-HEEP Register Map

> **Note:** These addresses are provisional and will be finalized during X-HEEP integration.

| Offset | Register | Access |
|---|---|---|
| `0x00` | `PLAINTEXT_0` | Write |
| `0x04` | `PLAINTEXT_1` | Write |
| `0x08` | `PLAINTEXT_2` | Write |
| `0x0C` | `PLAINTEXT_3` | Write |
| `0x10` | `KEY_0` | Write |
| `0x14` | `KEY_1` | Write |
| `0x18` | `KEY_2` | Write |
| `0x1C` | `KEY_3` | Write |
| `0x20` | `CONTROL` | Write |
| `0x24` | `STATUS` | Read |
| `0x28` | `CIPHERTEXT_0` | Read |
| `0x2C` | `CIPHERTEXT_1` | Read |
| `0x30` | `CIPHERTEXT_2` | Read |
| `0x34` | `CIPHERTEXT_3` | Read |

### Control Register

| Bit | Name | Description |
|---:|---|---|
| 0 | `START` | Writing `1` starts an AES-128 encryption operation |
| 31:1 | Reserved | Reserved for future use |

### Status Register

| Bit | Name | Description |
|---:|---|---|
| 0 | `BUSY` | `1` while encryption is in progress |
| 1 | `DONE` | `1` when encryption is complete |
| 31:2 | Reserved | Reserved for future use |

---

# 14. Software ↔ Hardware Data Mapping

The 128-bit values will be accessed as four 32-bit words.

### Plaintext

```text
PLAINTEXT_0 = 00112233
PLAINTEXT_1 = 44556677
PLAINTEXT_2 = 8899AABB
PLAINTEXT_3 = CCDDEEFF
```

### Key

```text
KEY_0 = 00010203
KEY_1 = 04050607
KEY_2 = 08090A0B
KEY_3 = 0C0D0E0F
```

### Expected Ciphertext

```text
CIPHERTEXT_0 = 69C4E0D8
CIPHERTEXT_1 = 6A7B0430
CIPHERTEXT_2 = D8CDB780
CIPHERTEXT_3 = 70B4C55A
```

---

# 15. Software Operation

The intended software flow is:

```text
Write Plaintext
      │
      ▼
Write Key
      │
      ▼
Set START
      │
      ▼
Wait for DONE
      │
      ▼
Read Ciphertext
      │
      ▼
Verify Result
```

The accelerator is multi-cycle, so software must wait for the encryption operation to complete before reading the ciphertext.

---

# 16. Project Directory

```text
AES128-XHEEP/
│
├── README.md
│
├── rtl/
│   ├── add_round_key.sv
│   ├── aes_core.sv
│   ├── aes_final_round.sv
│   ├── aes_round.sv
│   ├── aes_sbox.sv
│   ├── key_expansion.sv
│   ├── mix_columns.sv
│   ├── round_controller.sv
│   ├── shift_rows.sv
│   └── sub_bytes.sv
│
├── tb/
│   ├── add_round_key_tb.sv
│   ├── aes_core_tb.sv
│   ├── aes_final_round_tb.sv
│   ├── aes_round_tb.sv
│   ├── aes_sbox_tb.sv
│   ├── key_expansion_tb.sv
│   ├── mix_columns_tb.sv
│   ├── round_controller_tb.sv
│   ├── shift_rows_tb.sv
│   └── sub_bytes_tb.sv
│
├── sim/
│   └── ...
│
├── synth/
│   └── ...
│
└── constraints/
    └── ...
```

---

# 17. Future Work

The remaining development stages are:

1. **X-HEEP peripheral integration**
2. Memory-mapped register implementation
3. X-HEEP SoC integration
4. C driver development
5. Hardware/software verification
6. Software AES reference implementation
7. Hardware vs. software cycle benchmark
8. RTL synthesis
9. Timing analysis
10. Area analysis
11. Power analysis

---

# 18. Project Goal

The final system will demonstrate a complete hardware/software AES-128 accelerator integrated into an X-HEEP RISC-V SoC.

The target system is:

```text
                 X-HEEP SoC
                     │
              ┌──────┴──────┐
              │   RISC-V    │
              │     CPU     │
              └──────┬──────┘
                     │
              Memory-Mapped I/O
                     │
                     ▼
             ┌───────────────┐
             │ AES-128       │
             │ Accelerator   │
             └───────┬───────┘
                     │
                     ▼
                Ciphertext
```

The final evaluation will compare the hardware accelerator against a software AES implementation in terms of:

- Correctness
- Cycle count
- Latency
- Throughput
- Hardware area
- Timing
- Power
- Hardware/software speedup

---
