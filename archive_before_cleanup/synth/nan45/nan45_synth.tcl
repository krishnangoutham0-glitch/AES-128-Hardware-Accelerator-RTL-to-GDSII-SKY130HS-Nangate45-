# ============================================================
# AES-128 - Nangate45 Technology-Mapped Synthesis
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
# Set Top Module
# ------------------------------------------------------------

hierarchy -check -top aes_core


# ------------------------------------------------------------
# RTL -> Logic
# ------------------------------------------------------------

proc
opt

# ------------------------------------------------------------
# FSM optimization
# ------------------------------------------------------------

fsm_detect
fsm_extract
fsm_opt
fsm_recode -encoding one-hot
fsm_map

opt

memory
memory_map

techmap
opt


# ------------------------------------------------------------
# Map Flip-Flops
# ------------------------------------------------------------

dfflibmap -liberty /Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib


# ------------------------------------------------------------
# Map Combinational Logic
# ------------------------------------------------------------

#---------------------------------------------------------
# Map Combinational Logic
#---------------------------------------------------------

abc -D 9000 \
    -liberty /Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib

# ------------------------------------------------------------
# Final Optimization
# ------------------------------------------------------------

clean -purge
opt


# ------------------------------------------------------------
# Technology-Mapped Statistics
# ------------------------------------------------------------

stat

tee -o synth/reports/aes_core_synthesis.rpt stat -liberty /Users/gouthamkrishnan/PDK/OpenROAD-flow-scripts/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib


# ------------------------------------------------------------
# Write Synthesized Netlist
# ------------------------------------------------------------

write_verilog -noattr -simple-lhs synth/netlist/aes_core_nangate45.v


# ------------------------------------------------------------
# End
# ------------------------------------------------------------