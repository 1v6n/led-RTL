task automatic run_enable_iteration(ref int pass_count, ref int fail_count);
  reg [NLED - 1 : 0] pre_enable_led;
  reg [NLED - 1 : 0] mid_enable_led;
  begin
    reset_uut();

    pre_enable_led = o_led;
    repeat ($urandom_range(21, 40)) @(posedge i_clock);

    if (o_led != pre_enable_led) begin
      fail_count++;
      $warning("[%0t] [FAIL] o_led shifted while disabled. Start: %0d, Now: %0d", $time,
               pre_enable_led, o_led);
      return;
    end

    begin
      bit shifted;
      shifted = 1'b0;
      i_sw[0] = 1'b1;
      fork
        begin
          @(o_led);
          shifted = 1'b1;
        end
        begin
          repeat ($urandom_range(21, 40)) @(posedge i_clock);
        end
      join_any
      disable fork;

      if (!shifted) begin
        fail_count++;
        $warning("[%0t] [FAIL] o_led did not shift while enabled. Start: %0d, Now: %0d", $time,
                 pre_enable_led, o_led);
        return;
      end
    end

    mid_enable_led = o_led;

    i_sw[0]        = 1'b0;
    repeat ($urandom_range(21, 40)) @(posedge i_clock);
    if (o_led != mid_enable_led) begin
      fail_count++;
      $warning("[%0t] [FAIL] o_led did not freeze when disabled. Frozen at: %0d, Now: %0d", $time,
               mid_enable_led, o_led);
      return;
    end

    pass_count++;
  end
endtask

task automatic test_enable();
  int unsigned iterations;
  int          pass_count = 0;
  int          fail_count = 0;
  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_enable (%0d iterations)...", $time, iterations);

    for (int i = 0; i < iterations; i++) begin
      iteration_id = i;
      run_enable_iteration(pass_count, fail_count);
    end

    if (fail_count == 0) begin
      $display("[%0t] [PASS] test_enable completed successfully: %0d/%0d runs passed.", $time,
               pass_count, iterations);
    end else begin
      $error("[%0t] [FAIL] test_enable completed with errors: %0d failures out of %0d runs.",
             $time, fail_count, iterations);
    end
  end
endtask
