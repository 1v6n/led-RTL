task automatic run_random_shift_test(ref int pass_count, ref int fail_count);
  reg      [1:0] random_lim = 2'($urandom_range(0, 3));
  int            expected_lim;
  realtime       expected_period;
  realtime t1, t2;

  reset_uut();

  i_sw[2:1] = random_lim;

  unique case (random_lim)
    2'b00: expected_lim = SimLimit_0;
    2'b01: expected_lim = SimLimit_1;
    2'b10: expected_lim = SimLimit_2;
    2'b11: expected_lim = SimLimit_3;
  endcase

  expected_period = ((CLKPERIOD / 2) * 2) * (expected_lim + 1);

  @(posedge i_clock);

  i_sw[0] = 1'b1;

  @(posedge o_led[2]);

  t1 = $realtime;

  @(posedge o_led[1]);

  t2 = $realtime;

  if (t2 - t1 >= expected_period - 1 && t2 - t1 <= expected_period + 1) begin
    pass_count++;
  end else begin
    fail_count++;
    $warning("[%0t] [FAIL] Random shift test fail for limit %0d: Expected period ~%0t, got %0t",
             $time, expected_lim, expected_period, t2 - t1);
  end
endtask

`DEFINE_TEST_RUNNER(random_shift, run_random_shift_test(pass_count, fail_count),
                    pass_count + fail_count)

`DEFINE_TEST_SUITE(clock, `RUN_TEST_STEP(4, test_random_shift()))

`ifndef COMBINED_TESTS
initial begin
  run_test_clock_suite();
end
`endif

