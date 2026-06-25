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

`DEFINE_TEST_RUNNER(led, run_test_led(pass_count, fail_count), pass_count + fail_count)

`DEFINE_TEST_SUITE(led, `RUN_TEST_STEP(7, test_led()))

`ifndef COMBINED_TESTS
initial begin
  run_test_led_suite();
end
`endif

