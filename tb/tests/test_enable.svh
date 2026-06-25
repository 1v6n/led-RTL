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

`DEFINE_TEST_RUNNER(enable, run_enable_iteration(pass_count, fail_count), iterations)

`DEFINE_TEST_SUITE(enable, `RUN_TEST_STEP(3, test_enable()))

`ifndef COMBINED_TESTS
initial begin
  run_test_enable_suite();
end
`endif

