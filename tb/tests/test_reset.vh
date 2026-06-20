task automatic run_reset_iteration(input bit count_enabled, ref int pass_count, ref int fail_count);
  reg [NLED - 1 : 0] pre_reset_led;
  begin
    reset_uut();

    i_sw    = NSWITCH'($urandom);
    i_sw[0] = 1'b1;

    repeat ($urandom_range(21, 40)) @(posedge i_clock);

    if (count_enabled == 1'b0) begin
      i_sw[0] = 1'b0;
    end

    pre_reset_led = o_led;
    if (o_led == 4'b1000) begin
      $warning("[%0t] [WARN] o_led did not change state before reset. Test may be invalid.", $time);
    end

    #10ns;
    i_reset = 1'b0;
    #10ns;

    if (o_led == 4'b1000) begin
      pass_count++;
    end else begin
      fail_count++;
      $error({"[%0t] [FAIL] Reset Check Failed (Enabled=%b)! State details:\n",
              "       - Pre-reset LED state:  %b\n",
              "       - Post-reset LED state: %b (Expected: 1000)\n",
              "       - Switch settings:      %b\n"}, $time, count_enabled, pre_reset_led, o_led,
               i_sw);
    end

    i_reset = 1'b1;
    repeat (2) @(posedge i_clock);
  end
endtask

task automatic test_reset();
  int iterations;
  int pass_count = 0;
  int fail_count = 0;

  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_reset (%0d iterations)...", $time, iterations);

    repeat (iterations) begin
      run_reset_iteration(.count_enabled(1'b1), .pass_count(pass_count), .fail_count(fail_count));
    end

    if (fail_count == 0) begin
      $display("[%0t] [PASS] test_reset completed successfully: %0d/%0d runs passed.", $time,
               pass_count, iterations);
    end else begin
      $error("[%0t] [FAIL] test_reset completed with errors: %0d failures out of %0d runs.", $time,
             fail_count, iterations);
    end
  end
endtask

task automatic test_reset_disable();
  int iterations;
  int pass_count = 0;
  int fail_count = 0;

  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_reset_disable (%0d iterations)...", $time, iterations);

    repeat (iterations) begin
      run_reset_iteration(.count_enabled(1'b0), .pass_count(pass_count), .fail_count(fail_count));
    end

    if (fail_count == 0) begin
      $display("[%0t] [PASS] test_reset_disable completed successfully: %0d/%0d runs passed.",
               $time, pass_count, iterations);
    end else begin
      $error("[%0t] [FAIL] test_reset_disable completed with errors: %0d failures out of %0d runs.",
             $time, fail_count, iterations);
    end
  end
endtask
