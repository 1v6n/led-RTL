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

`DEFINE_TEST_RUNNER(reset, run_reset_iteration(.count_enabled(1'b1), .pass_count(pass_count),
                                               .fail_count(fail_count)), iterations)

`DEFINE_TEST_RUNNER(reset_disable, run_reset_iteration(.count_enabled(1'b0),
                                                       .pass_count(pass_count),
                                                       .fail_count(fail_count)), iterations)

`DEFINE_TEST_SUITE(reset,
                   `RUN_TEST_STEP(1, test_reset())
  `RUN_TEST_STEP(2, test_reset_disable()))

`ifndef COMBINED_TESTS
initial begin
  run_test_reset_suite();
end
`endif

