set_property SRC_FILE_INFO {cfile:/home/morten/dev/risc-v-cpu/constraints/ArtyA7.xdc rfile:../constraints/ArtyA7.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:7 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=gclk[100]
set_property src_info {type:XDC file:1 line:37 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { rstn }]; #IO_L6N_T0_VREF_16 Sch=btn[0]
set_property src_info {type:XDC file:1 line:44 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { spi_io_sck }]; #IO_0_15 Sch=ja[1]
set_property src_info {type:XDC file:1 line:45 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { spi_io_mosi }]; #IO_L4P_T0_15 Sch=ja[2]
set_property src_info {type:XDC file:1 line:46 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { spi_io_csn }]; #IO_L4N_T0_15 Sch=ja[3]
set_property src_info {type:XDC file:1 line:55 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E15   IOSTANDARD LVCMOS33 } [get_ports { load_program }]; #IO_L11P_T1_SRCC_15 Sch=jb_p[1]
set_property src_info {type:XDC file:1 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { mem_loader_SCK}]; #IO_L11N_T1_SRCC_15 Sch=jb_n[1]
set_property src_info {type:XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D15   IOSTANDARD LVCMOS33 } [get_ports { mem_loader_CSn }]; #IO_L12P_T1_MRCC_15 Sch=jb_p[2]
set_property src_info {type:XDC file:1 line:58 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { mem_loader_MOSI }]; #IO_L12N_T1_MRCC_15 Sch=jb_n[2]
set_property src_info {type:XDC file:1 line:59 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { mem_loader_MISO }]; #IO_L23P_T3_FOE_B_15 Sch=jb_p[3]
