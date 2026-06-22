TARGET ?= tb_top_led
SEED ?= $(shell date +%s)
ARGS ?=

all: sim

sim:
	@echo "Running simulation with SEED=$(SEED)"
	./tools/run_sim.sh $(TARGET) +verilator+seed+$(SEED) $(ARGS) | tee simulation.log

lint:
	./tools/verilator_lint.sh
	pre-commit run --all-files

wave:
	gtkwave sim_output.vcd &

clean:
	rm -rf obj_dir sim.f sim_output.vcd simulation.log

.PHONY: all sim lint wave clean
