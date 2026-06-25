task automatic run_limit_test(ref int pass_count, ref int fail_count);
  begin
    reset_uut();
    i_sw[2:1] = 2'b00;
    i_sw[0]   = 1'b1;
    repeat (SimLimit_0 + 1) @(posedge i_clock);
    @(negedge i_clock);
    if (o_led[2] == 1'b1) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Limit test fail for limit 0: Expected o_led[2] = 1, got %b", $time,
               o_led[2]);
    end

    reset_uut();
    i_sw[2:1] = 2'b01;
    i_sw[0]   = 1'b1;
    repeat (SimLimit_1 + 1) @(posedge i_clock);
    @(negedge i_clock);
    if (o_led[2] == 1'b1) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Limit test fail for limit 1: Expected o_led[2] = 1, got %b", $time,
               o_led[2]);
    end

    reset_uut();
    i_sw[2:1] = 2'b10;
    i_sw[0]   = 1'b1;
    repeat (SimLimit_2 + 1) @(posedge i_clock);
    @(negedge i_clock);
    if (o_led[2] == 1'b1) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Limit test fail for limit 2: Expected o_led[2] = 1, got %b", $time,
               o_led[2]);
    end

    reset_uut();
    i_sw[2:1] = 2'b11;
    i_sw[0]   = 1'b1;
    repeat (SimLimit_3 + 1) @(posedge i_clock);
    @(negedge i_clock);
    if (o_led[2] == 1'b1) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Limit test fail for limit 3: Expected o_led[2] = 1, got %b", $time,
               o_led[2]);
    end

    reset_uut();
    i_sw[2:1] = 2'b11;
    i_sw[0]   = 1'b1;
    repeat (SimLimit_3) @(posedge i_clock);
    @(negedge i_clock);
    i_sw[2:1] = 2'b01;
    repeat (1) @(posedge i_clock);
    @(negedge i_clock);
    if (o_led[2] == 1'b1) begin
      pass_count++;
    end else begin
      fail_count++;
      $warning("[%0t] [FAIL] Limit test fail for limit 0: Expected o_led[2] = 1, got %b", $time,
               o_led[2]);
    end

  end

endtask

`DEFINE_TEST_RUNNER(limit, run_limit_test(pass_count, fail_count), pass_count + fail_count)

`DEFINE_TEST_SUITE(limit, `RUN_TEST_STEP(5, test_limit()))

`ifndef COMBINED_TESTS
initial begin
  run_test_limit_suite();
end
`endif

