TARGET ?= tb_top_led
SEED ?= $(shell date +%s)
ARGS ?=

ALL_TESTS = $(wildcard tb/tests/test_*.svh)

TEST_NAME = $(basename $(notdir $(TESTFILE)))

all: sim

sim:
ifdef TESTFILE
	@$(MAKE) -s run_single_sim TESTFILE=$(TESTFILE)
else
	@echo "============================================================"
	@echo "Running all tests combined in a single simulation process"
	@echo "============================================================"
	./tools/run_sim.sh $(TARGET) +verilator+seed+$(SEED) +VCD=sim_output_all.vcd $(ARGS) | tee simulation.log
endif

run_single_sim:
	TESTFILE=$(TESTFILE) ./tools/run_sim.sh $(TARGET) +verilator+seed+$(SEED) +VCD=sim_output_$(TEST_NAME).vcd $(ARGS) | tee simulation.log

lint:
	./tools/verilator_lint.sh
	pre-commit run --all-files

wave:
	gtkwave sim_output_$(TEST_NAME).vcd &

clean:
	rm -rf obj_dir sim.f sim_output*.vcd simulation.log

.PHONY: all sim lint wave clean
