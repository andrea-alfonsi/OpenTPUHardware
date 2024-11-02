ROOT_DIR    := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TARGET_DIR  := ${ROOT_DIR}/build

# Using icarus verilog as default compiler. 
COMPILER    := iverilog -g2012 -Wall

# Let the execution run for at most 60 seconds. Simulations should be way shorter mut you can increase this value if you need
INTERPRETER := timeout --foreground 60s vvp

clean: 
	rm -r ${TARGET_DIR}

.PHONY: test_all
test_all: test_basic_pe test_redas_pe test_monodirectional_systolic_array test_roundabout_systolic_array test_brent_kung_adder test_instruction_decoder

.PHONY: test_basic_pe
test_basic_pe:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/basic_pe_tb.test sim/core/processing_elements/basic_pe/basic_pe_tb.sv
	${INTERPRETER} ${TARGET_DIR}/basic_pe_tb.test

.PHONY: test_redas_pe
test_redas_pe:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/redas_pe_tb.test sim/core/processing_elements/redas_pe/redas_pe_tb.sv
	${INTERPRETER} ${TARGET_DIR}/redas_pe_tb.test

.PHONY: test_monodirectional_systolic_array
test_monodirectional_systolic_array:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/monodirectional_systolic_array_tb.test sim/core/systolic_arrays/monodirectional_systolic_array/monodirectional_systolic_array_tb.sv
	${INTERPRETER} ${TARGET_DIR}/monodirectional_systolic_array_tb.test

.PHONY: test_roundabout_systolic_array
test_roundabout_systolic_array:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/roundabout_systolic_array_tb.test sim/core/systolic_arrays/roundabout_systolic_array/roundabout_systolic_array_tb.sv
	${INTERPRETER} ${TARGET_DIR}/roundabout_systolic_array_tb.test

.PHONY: test_brent_kung_adder
test_brent_kung_adder:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/brent_kung_adder_tb.test sim/core/arithmetic/adders/brent_kung_adder/brent_kung_adder_tb.sv
	${INTERPRETER} ${TARGET_DIR}/brent_kung_adder_tb.test

.PHONY: test_instruction_decoder
test_instruction_decoder:
	@mkdir -p build
	${COMPILER} -o ${TARGET_DIR}/instruction_decoder_tb.test sim/core/control/instruction_decoder/instruction_decoder_tb.sv
	${INTERPRETER} ${TARGET_DIR}/instruction_decoder_tb.test
