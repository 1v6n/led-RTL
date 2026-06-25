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
      @(negedge i_clock);
    end
  endtask

  string vcd_file;
  initial begin
    $timeformat(-6, 3, " us", 10);
    if ($value$plusargs("VCD=%s", vcd_file)) begin
      $dumpfile(vcd_file);
    end else begin
      $dumpfile("sim_output.vcd");
    end
    $dumpvars(0, tb_top_led);
  end

  `include "tests/macros.svh"
`ifdef COMBINED_TESTS
  `include "tests/combined_tests.svh"
`else
  `include "current_test.svh"
`endif
endmodule

