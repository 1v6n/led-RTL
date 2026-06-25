`ifndef TEST_MACROS_SVH
`define TEST_MACROS_SVH

`define RUN_TEST_STEP(ID, TEST_CALL) \
  test_id = ID; \
  TEST_CALL; \
  repeat (2) @(posedge i_clock);

`define DEFINE_TEST_SUITE(NAME, STEPS) \
  task automatic run_test_``NAME``_suite(); \
    $display("--- Running ", `"NAME`", " Test Suite ---"); \
    STEPS \
    test_id = 0; \
    $display("--- All ", `"NAME`", " Tests Completed ---"); \
    `ifndef COMBINED_TESTS \
    $finish; \
    `endif \
  endtask

`define DEFINE_TEST_RUNNER(NAME, ITERATION_CALL, TOTAL_EXPR) \
  task automatic test_``NAME``(); \
    int unsigned iterations; \
    int          pass_count = 0; \
    int          fail_count = 0; \
    begin \
      iterations = $urandom_range(50, 100); \
      $display("[%0t] [INFO] Starting test_%s (%0d iterations)...", $time, `"NAME`", iterations); \
      for (int i = 0; i < iterations; i++) begin \
        iteration_id = i; \
        ITERATION_CALL; \
      end \
      if (fail_count == 0) begin \
        $display("[%0t] [PASS] test_%s completed successfully: %0d/%0d checks passed.", $time, \
                 `"NAME`", pass_count, TOTAL_EXPR); \
      end else begin \
        $error("[%0t] [FAIL] test_%s completed with errors: %0d failures out of %0d runs.", $time, \
               `"NAME`", fail_count, TOTAL_EXPR); \
      end \
    end \
  endtask

`endif  // TEST_MACROS_SVH

