# ============================================================
# AES-128 Accelerator - SKY130HS Synthesis
# ============================================================
#
# Technology : SKY130 130nm
# Library    : sky130_fd_sc_hs
# Corner     : TT 25C 1.80V
# Top        : aes_core
# ============================================================


# ------------------------------------------------------------
# Read RTL
# ------------------------------------------------------------

read_verilog -sv rtl/aes_sbox.sv
read_verilog -sv rtl/sub_bytes.sv
read_verilog -sv rtl/shift_rows.sv
read_verilog -sv rtl/mix_columns.sv
read_verilog -sv rtl/add_round_key.sv
read_verilog -sv rtl/key_expansion.sv
read_verilog -sv rtl/aes_round.sv
read_verilog -sv rtl/aes_final_round.sv
read_verilog -sv rtl/round_controller.sv
read_verilog -sv rtl/aes_core.sv


# ------------------------------------------------------------
# Set top module
# ------------------------------------------------------------

hierarchy -check -top aes_core


# ------------------------------------------------------------
# RTL synthesis
# ------------------------------------------------------------

proc
opt

fsm
opt

memory
memory_map

techmap
opt


# ------------------------------------------------------------
# SKY130HS flip-flop mapping
# ------------------------------------------------------------

dfflibmap -liberty \
/Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/sky130hs/lib/sky130_fd_sc_hs__tt_025C_1v80.lib


# ------------------------------------------------------------
# SKY130HS combinational mapping
# ------------------------------------------------------------

abc -liberty \
/Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/sky130hs/lib/sky130_fd_sc_hs__tt_025C_1v80.lib


# ------------------------------------------------------------
# Final optimization
# ------------------------------------------------------------

clean -purge
opt


# ------------------------------------------------------------
# Statistics
# ------------------------------------------------------------

stat

stat -liberty \
/Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/sky130hs/lib/sky130_fd_sc_hs__tt_025C_1v80.lib


# ------------------------------------------------------------
# Write gate-level netlist
# ------------------------------------------------------------

write_verilog -noattr -simple-lhs \
synth/sky130hs/netlist/sky130hs_aes_core.v


# ------------------------------------------------------------
# Save synthesis report
# ------------------------------------------------------------

tee -o synth/sky130hs/reports/sky130hs_synthesis.rpt stat


# ------------------------------------------------------------
# End
# ------------------------------------------------------------