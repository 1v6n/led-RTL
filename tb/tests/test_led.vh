task automatic run_test_led(ref int pass_count, ref int fail_count);
  begin
    reset_uut();
    i_sw = NSWITCH'($urandom);
    repeat ($urandom_range(1, 10)) @(posedge i_clock);
    if (i_sw[3] == 1'b1) begin
      if (o_led_b == '1 && o_led_g == '0) begin
        pass_count++;
      end else begin
        fail_count++;
        $warning("[%0t] [FAIL] o_led_b is low and o_led_g is high when i_sw[3] is high.", $time);
      end
    end else if (i_sw[3] == 1'b0) begin
      if (o_led_b == '0 && o_led_g == '1) begin
        pass_count++;
      end else begin
        fail_count++;
        $warning("[%0t] [FAIL] o_led_b is high and o_led_g is low when i_sw[3] is low.", $time);
      end
    end
  end
endtask

task automatic test_led();
  int unsigned iterations;
  int          pass_count = 0;
  int          fail_count = 0;
  begin
    iterations = $urandom_range(50, 100);
    $display("[%0t] [INFO] Starting test_led (%0d iterations)...", $time, iterations);
    for (int i = 0; i < iterations; i++) begin
      iteration_id = i;
      run_test_led(pass_count, fail_count);
    end
    if (fail_count == 0) begin
      $display("[%0t] [PASS] test_led completed successfully: %0d/%0d checks passed.", $time,
               pass_count, pass_count + fail_count);
    end else begin
      $error("[%0t] [FAIL] test_led completed with errors: %0d failures out of %0d runs.", $time,
             fail_count, iterations);
    end
  end
endtask

