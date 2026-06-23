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
      #1ps;
      i_sw[2:1] = 2'($urandom_range(0, 3));
    end
  end
endtask

task automatic run_checker_model(input int num_cycles, output int pass_count,
                                 output int fail_count);
  int       expected_counter = 0;
  reg [3:0] expected_leds = 4'b1000;
  begin
    pass_count = 0;
    fail_count = 0;
    repeat (num_cycles) begin
      step_reference_model(i_sw[0], i_sw[2:1], expected_counter, expected_leds);

      @(posedge i_clock);

      if (o_led !== expected_leds) begin
        fail_count++;
        $error({"[%0t] [FAIL] Random limit mismatch! ",
                "o_led = %b (Expected: %b), Switch: %b, Expected Counter: %0d"}, $time, o_led,
                 expected_leds, i_sw[2:1], expected_counter);
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
    cycles    = $urandom_range(100, 200);

    fork
      begin
        random_limit_change();
      end

      begin
        run_checker_model(cycles, local_pass, local_fail);
      end
    join_any
    disable fork;

    pass_count += local_pass;
    fail_count += local_fail;
  end
endtask

task automatic test_random_limit();
  int unsigned iterations;
  int          pass_count = 0;
  int          fail_count = 0;
  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_random_limit (%0d iterations)...", $time, iterations);
    for (int i = 0; i < iterations; i++) begin
      iteration_id = i;
      run_limit_random_test(pass_count, fail_count);
    end
    if (fail_count == 0) begin
      $display("[%0t] [PASS] test_random_limit completed successfully: %0d/%0d checks passed.",
               $time, pass_count, pass_count + fail_count);
    end else begin
      $error("[%0t] [FAIL] test_random_limit completed with errors: %0d failures out of %0d runs.",
             $time, fail_count, iterations);
    end
  end
endtask
