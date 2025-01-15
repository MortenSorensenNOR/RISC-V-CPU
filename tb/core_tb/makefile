SRC_DIR = ../../src
MODULE=core

IMPORTS=\
	$(SRC_DIR)/if_stage.sv \
	$(SRC_DIR)/IF_ID_Reg.sv \
	$(SRC_DIR)/controller.sv \
	$(SRC_DIR)/immediate_generator.sv \
	$(SRC_DIR)/register_file.sv \
	$(SRC_DIR)/id_stage.sv \
	$(SRC_DIR)/ID_EX_Reg.sv \
	$(SRC_DIR)/alu_controller.sv \
	$(SRC_DIR)/alu.sv \
	$(SRC_DIR)/forwarding_unit.sv \
	$(SRC_DIR)/ex_stage.sv \
	$(SRC_DIR)/EX_MEM_Reg.sv \
	$(SRC_DIR)/load_store_stage.sv \
	$(SRC_DIR)/MEM_WB_Reg.sv \
	$(SRC_DIR)/wb_stage.sv

.PHONY:sim
sim: waveform.vcd

.PHONY:verilate
verilate: .stamp.verilate

.PHONY:build
build: obj_dir/V$(MODULE)

.PHONY:waves
waves: waveform.vcd
	@echo
	@echo "### WAVES ###"
	gtkwave waveform.vcd

waveform.vcd: ./obj_dir/V$(MODULE)
	@echo
	@echo "### SIMULATING ###"
	@./obj_dir/V$(MODULE) +verilator+rand+reset+2

./obj_dir/V$(MODULE): .stamp.verilate
	@echo
	@echo "### BUILDING SIM ###"
	make -C obj_dir -f V$(MODULE).mk V$(MODULE)

.stamp.verilate: $(SRC_DIR)/$(MODULE).sv $(IMPORTS) $(MODULE)_tb.cpp
	@echo
	@echo "### VERILATING ###"
	verilator -Wall --trace --x-assign unique --x-initial unique \
		-cc $(SRC_DIR)/$(MODULE).sv $(IMPORTS) --exe $(MODULE)_tb.cpp
	@touch .stamp.verilate

.PHONY:lint
lint: $(MODULE).sv
	verilator --lint-only $(MODULE).sv

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd

