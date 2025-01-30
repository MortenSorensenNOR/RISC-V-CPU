set design_name "design_name"
set board_name "board_name"

# Arty A7 100T FPGA
set fpga_part "xc7a100tcsg324-1"

set src_dir [file normalize "./../src"]
set origin_dir [file normalize "./../"]

# Create log directory
file mkdir logs

# Read lib files
read_verilog -sv "${lib_dir}/some_file.sv"

# Read src files
add_files "${src_dir}/some_file.mem"
read_verilog -sv "${src_dir}/some_source_file.sv"

# Read constraints
read_xdc "${origin_dir}/constraints/${board_name}.xdc"

# Synthesis
synth_design -top "${design_name}" -part ${fpga_part}

# Optimize design
opt_design

# Place design
place_design

# Route design
route_design

# Generate Timing Reports

# 1. Generate Timing Summary Report
report_timing_summary -file logs/timing_summary.txt

# 2. Generate Detailed Timing Report (Top 10 Critical Paths)
report_timing -delay_type max -sort_by slack -max_paths 10 -file logs/detailed_timing_report.txt

# # Write bitstream -- Optional
# set_property BITSTREAM.Config.SPI_buswidth 4 [current_design]
# write_bitstream -force "${origin_dir}/Build/output/${design_name}.bit"
#
# write_cfgmem -format bin -force \
#   -size 16 \
#   -interface spix4 \
#   -loadbit "up 0x0 ${origin_dir}/Build/output/${design_name}.bit" \
#   -file "${origin_dir}/Build/output/${design_name}.bin"
