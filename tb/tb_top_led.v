`timescale 1ps / 1ps
/* verilator lint_off UNUSEDSIGNAL */

module tb_top_led;

  localparam NSWITCH = 4;
  localparam NLED = 4;
  localparam CLKPERIOD = 83333;

  reg                    i_clock;
  reg                    i_reset;
  reg  [NSWITCH - 1 : 0] i_sw;
  wire [NLED    - 1 : 0] o_led;
  wire [NLED    - 1 : 0] o_led_b;
  wire [NLED    - 1 : 0] o_led_g;
  localparam SimLimit_0 = 32'd1;
  localparam SimLimit_1 = 32'd2;
  localparam SimLimit_2 = 32'd3;
  localparam SimLimit_3 = 32'd4;
  integer iteration_id = 0;
  integer test_id = 0;
  bit     cfg_run_reset;
  bit     cfg_run_reset_disable;
  bit     cfg_run_enable;
  bit     cfg_run_clock;
  bit     cfg_run_limit;
  bit     cfg_run_random_limit;
  bit     cfg_run_led;
  bit     has_test_filter;
  string  test_name;

  top_led #(
      .N_SWITCH(NSWITCH),
      .N_LED   (NLED),
      .LIMIT_0 (SimLimit_0),
      .LIMIT_1 (SimLimit_1),
      .LIMIT_2 (SimLimit_2),
      .LIMIT_3 (SimLimit_3)
  ) uut (
      .i_clock(i_clock),
      .i_reset(i_reset),
      .i_sw   (i_sw),
      .o_led  (o_led),
      .o_led_b(o_led_b),
      .o_led_g(o_led_g)
  );

  initial begin
    i_clock = 1'b0;
    forever begin
      #(CLKPERIOD / 2);
      i_clock = ~i_clock;
    end
  end

  task automatic reset_uut();
    begin
      i_sw    = '0;
      i_reset = 1'b0;
      repeat (2) @(posedge i_clock);
      i_reset = 1'b1;
      repeat (2) @(posedge i_clock);
    end
  endtask

  `include "tests/test_reset.vh"
  `include "tests/test_enable.vh"
  `include "tests/test_clock.vh"
  `include "tests/test_limit.vh"
  `include "tests/test_random_limit.vh"
  `include "tests/test_led.vh"

  initial begin
    $timeformat(-6, 3, " us", 10);
    $dumpfile("sim_output.vcd");
    $dumpvars(0, tb_top_led);

    has_test_filter       = $value$plusargs("TEST=%s", test_name);

    cfg_run_reset         = !has_test_filter || (test_name == "test_reset");
    cfg_run_reset_disable = !has_test_filter || (test_name == "test_reset_disable");
    cfg_run_enable        = !has_test_filter || (test_name == "test_enable");
    cfg_run_clock         = !has_test_filter || (test_name == "test_clock");
    cfg_run_limit         = !has_test_filter || (test_name == "test_limit");
    cfg_run_random_limit  = !has_test_filter || (test_name == "test_random_limit");
    cfg_run_led           = !has_test_filter || (test_name == "test_led");

    $display("--- Running Main Test Suite ---");

    if (cfg_run_reset) begin
      test_id = 1;
      test_reset();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_reset_disable) begin
      test_id = 2;
      test_reset_disable();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_enable) begin
      test_id = 3;
      test_enable();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_clock) begin
      test_id = 4;
      test_random_shift();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_limit) begin
      test_id = 5;
      test_limit();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_random_limit) begin
      test_id = 6;
      test_random_limit();
      repeat (2) @(posedge i_clock);
    end

    if (cfg_run_led) begin
      test_id = 7;
      test_led();
      repeat (2) @(posedge i_clock);
    end

    test_id = 0;
    $display("--- All Tests Completed ---");
    $finish;
  end

endmodule
