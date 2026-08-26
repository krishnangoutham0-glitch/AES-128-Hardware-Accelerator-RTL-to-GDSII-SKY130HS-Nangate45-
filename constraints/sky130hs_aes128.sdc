# ============================================================
# AES-128 Core - Timing Constraints
# Technology: Nangate45
# Target frequency: 100 MHz
# Clock period: 10 ns
# ============================================================

# ------------------------------------------------------------
# Clock
# ------------------------------------------------------------

create_clock -name clk -period 10.0 [get_ports clk]

# ------------------------------------------------------------
# Clock uncertainty
# ------------------------------------------------------------

set_clock_uncertainty 0.2 [get_clocks clk]

# ------------------------------------------------------------
# Input delays
# ------------------------------------------------------------

set_input_delay 1.0 -clock clk [get_ports start]

set_input_delay 1.0 -clock clk [get_ports plaintext*]

set_input_delay 1.0 -clock clk [get_ports key*]

# ------------------------------------------------------------
# Output delays
# ------------------------------------------------------------

set_output_delay 1.0 -clock clk [get_ports ciphertext*]

set_output_delay 1.0 -clock clk [get_ports busy]

set_output_delay 1.0 -clock clk [get_ports done]

# ------------------------------------------------------------
# Reset
# ------------------------------------------------------------

set_input_delay 0.0 -clock clk [get_ports rst_n]
set_false_path -from [get_ports rst_n]

# ------------------------------------------------------------
# End of constraints
# ============================================================
