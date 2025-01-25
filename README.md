# RISC-V-CPU
Building a RISC-V compliant CPU in SystemVerilog.  
Testing done in Verilator.

## Supported instructions
For now most of the RV32I extention is implemented except for *ecall* and *ebreak*. The plan is to further implement the RV32M and later RV32F extentions.

## Architecture
For now just a simple 5 stage pipeline. The plan is to add branch predicion, caching and external DDR memory through an AXI DMA interface.
