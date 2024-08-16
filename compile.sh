#!/bin/bash

# Compile individual components
ghdl -a --workdir=work --ieee=synopsys --std=08 iitb_risc_lib.vhd
ghdl -a --workdir=work --ieee=synopsys --std=08 components/arith_logic_pipeline/alu.vhd
ghdl -a --workdir=work --ieee=synopsys --std=08 components/*.vhd

# Compile top-level design and testbench
ghdl -a --workdir=work --ieee=synopsys --std=08 iitb_risc.vhd
ghdl -a --workdir=work --ieee=synopsys --std=08 iitb_risc_tb.vhd

# Run simulation and generate VCD file
ghdl -r --workdir=work --ieee=synopsys --std=08 iitb_risc_tb --vcd=waveform.vcd

# Open the waveform in GTKWave
gtkwave waveform.vcd
