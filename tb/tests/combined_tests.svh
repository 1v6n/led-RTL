`include "tests/test_reset.svh"
`include "tests/test_enable.svh"
`include "tests/test_clock.svh"
`include "tests/test_limit.svh"
`include "tests/test_random_limit.svh"
`include "tests/test_led.svh"

initial begin
  $timeformat(-6, 3, " us", 10);
  if ($value$plusargs("VCD=%s", vcd_file)) begin
    $dumpfile(vcd_file);
  end else begin
    $dumpfile("sim_output.vcd");
  end
  $dumpvars(0, tb_top_led);

  $display("--- Running Combined Test Suite ---");

  run_test_reset_suite();
  run_test_enable_suite();
  run_test_clock_suite();
  run_test_limit_suite();
  run_test_random_limit_suite();
  run_test_led_suite();

  $finish;
end
