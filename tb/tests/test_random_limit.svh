task automatic step_reference_model(input bit enable, input bit [1:0] limit_sel, ref int counter,
                                    ref reg [NLED - 1 : 0] leds);
  int limits                           [4] = '{SimLimit_0, SimLimit_1, SimLimit_2, SimLimit_3};
  int active_limit = limits[limit_sel];
  int next_counter;

  if (enable) begin
    if (counter >= active_limit) begin
      next_counter = 0;
    end else begin
      next_counter = counter + 1;
    end
  end else begin
    next_counter = counter;
  end

  if (counter == 0 && enable) begin
    leds = {leds[0], leds[NLED-1:1]};
  end

  counter = next_counter;
endtask

task automatic random_limit_change();
  begin
    forever begin
      repeat ($urandom_range(1, 15)) @(posedge i_clock);
      #1000ps;
      i_sw[2:1] = 2'($urandom_range(0, 3));
    end
  end
endtask

task automatic run_checker_model(output int pass_count, output int fail_count);
  int                expected_counter = 0;
  reg          [3:0] expected_leds = 4'b1000;
  int unsigned       num_cycles = $urandom_range(100, 200);
  reg          [1:0] sampled_limit_sel;
  bit                sampled_enable;
  begin

    pass_count = 0;
    fail_count = 0;
    repeat (num_cycles) begin
      @(posedge i_clock);
      #500ps;
      sampled_limit_sel = i_sw[2:1];
      sampled_enable    = i_sw[0];
      step_reference_model(sampled_enable, sampled_limit_sel, expected_counter, expected_leds);
      if (o_led !== expected_leds) begin
        fail_count++;
        $error("[%0t] [FAIL] Random limit mismatch! o_led=%b (Exp:%b) Sw:%b", $time, o_led,
               expected_leds, sampled_limit_sel);
      end else begin
        pass_count++;
      end
    end
  end
endtask

task automatic run_limit_random_test(ref int pass_count, ref int fail_count);
  int local_pass = 0;
  int local_fail = 0;
  int cycles;
  begin
    reset_uut();
    i_sw[2:1] = 2'b00;
    i_sw[0]   = 1'b1;

    fork
      begin
        random_limit_change();
      end

      begin
        run_checker_model(local_pass, local_fail);
      end
    join_any
    disable fork;

    pass_count += local_pass;
    fail_count += local_fail;
  end
endtask

`DEFINE_TEST_RUNNER(random_limit, run_limit_random_test(pass_count, fail_count),
                    pass_count + fail_count)

`DEFINE_TEST_SUITE(random_limit, `RUN_TEST_STEP(6, test_random_limit()))

`ifndef COMBINED_TESTS
initial begin
  run_test_random_limit_suite();
end
`endif

