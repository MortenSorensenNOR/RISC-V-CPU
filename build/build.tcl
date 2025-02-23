set design_name "top"
set board_name "ArtyA7"

# Arty A7 100T FPGA
set fpga_part "xc7a100tcsg324-1"

set src_dir [file normalize "./src"]
set origin_dir [file normalize "./"]

# Create log directory
file mkdir logs

# Read lib files
read_verilog -sv "${src_dir}/if_stage.sv"
read_verilog -sv "${src_dir}/IF_ID_Reg.sv"
read_verilog -sv "${src_dir}/controller.sv"
read_verilog -sv "${src_dir}/immediate_generator.sv"
read_verilog -sv "${src_dir}/register_file.sv"
read_verilog -sv "${src_dir}/id_stage.sv"
read_verilog -sv "${src_dir}/ID_EX_Reg.sv"
read_verilog -sv "${src_dir}/alu_controller.sv"
read_verilog -sv "${src_dir}/alu.sv"
read_verilog -sv "${src_dir}/forwarding_unit.sv"
read_verilog -sv "${src_dir}/ex_stage.sv"
read_verilog -sv "${src_dir}/EX_MEM_Reg.sv"
read_verilog -sv "${src_dir}/load_store_stage.sv"
read_verilog -sv "${src_dir}/MEM_WB_Reg.sv"
read_verilog -sv "${src_dir}/wb_stage.sv"
read_verilog -sv "${src_dir}/hazard_unit.sv"
read_verilog -sv "${src_dir}/i_mem.sv"
read_verilog -sv "${src_dir}/d_mem.sv"
read_verilog -sv "${src_dir}/core.sv"
read_verilog -sv "${src_dir}/spi_slave.sv"
read_verilog -sv "${src_dir}/spi_master.sv"
read_verilog -sv "${src_dir}/spi_io.sv"
read_verilog -sv "${src_dir}/spi_program_loader.sv"

# Mem files
add_files "${origin_dir}/programs/program.hex"

# Read src files
read_verilog -sv "${src_dir}/${design_name}.sv"

# Read constraints
read_xdc "${origin_dir}/constraints/${board_name}.xdc"

# Synthesis
synth_design -top "${design_name}" -part ${fpga_part}

# # Optimize design
# opt_design
#
# # Place design
# place_design
#
# # Route design
# route_design
#
# # Generate Timing Reports
#
# # 1. Generate Timing Summary Report
# report_timing_summary -file logs/timing_summary.txt
#
# # 2. Generate Detailed Timing Report (Top 10 Critical Paths)
# report_timing -delay_type max -sort_by slack -max_paths 10 -file logs/detailed_timing_report.txt
#
# # Write bitstream
# write_bitstream -force "${origin_dir}/build/output/${design_name}.bit"
