task automatic run_reset_iteration(input bit count_enabled, ref int pass_count, ref int fail_count);
  bit changed_state;
  begin
    reset_uut();

    i_sw          = NSWITCH'($urandom);
    i_sw[0]       = 1'b1;

    changed_state = 1'b0;
    for (int i = 0; i < $urandom_range(21, 40); i++) begin
      @(posedge i_clock);
      if (o_led != 4'b1000) begin
        changed_state = 1'b1;
      end
    end

    if (count_enabled == 1'b0) begin
      i_sw[0] = 1'b0;
    end

    if (!changed_state) begin
      $warning("[%0t] [WARN] o_led did not change state before reset. Test may be invalid.", $time);
    end

    #10ns;
    i_reset = 1'b0;
    #10ns;

    if (o_led == 4'b1000) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Reset Check Failed\n", $time);
    end

    i_reset = 1'b1;
    repeat (2) @(posedge i_clock);
  end
endtask

task automatic test_reset();
  int unsigned iterations;
  int          pass_count = 0;
  int          fail_count = 0;

  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_reset (%0d iterations)...", $time, iterations);

    for (int i = 0; i < iterations; i++) begin
      iteration_id = i;
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
  int unsigned iterations;
  int          pass_count = 0;
  int          fail_count = 0;

  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_reset_disable (%0d iterations)...", $time, iterations);

    for (int i = 0; i < iterations; i++) begin
      iteration_id = i;
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
