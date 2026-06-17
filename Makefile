all: sim

sim:
	./tools/run_sim.sh

lint:
	./tools/verilator_lint.sh
	pre-commit run --all-files

wave:
	gtkwave sim_output.vcd &

clean:
	rm -rf obj_dir sim.f sim_output.vcd

.PHONY: all sim lint wave clean
