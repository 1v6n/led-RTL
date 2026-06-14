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

  top_led #(
      .N_SWITCH(NSWITCH),
      .N_LED   (NLED)
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

  task reset_uut();
    begin
      i_reset = 1'b0;
      repeat (5) @(posedge i_clock);
      i_reset = ~i_reset;
    end
  endtask

  task test_reset();
    begin
      reset_uut();
      assert (o_led == 4'b1000) $display("o_led reset test pass");
      else $error("o_led reset test fail");
    end
  endtask

  task test_clock();
    realtime t1;
    realtime t2;
    realtime period;
    begin
      @(posedge i_clock);
      t1 = $realtime;
      @(posedge i_clock);
      t2     = $realtime;

      period = t2 - t1;
      $display(period);
      assert (period >= CLKPERIOD - 1 && period <= CLKPERIOD + 1) $display("Period test pass");
      else $error("Period test fail");
    end
  endtask

  task test_limit();
    begin
      i_sw[2:1] = 2'b00;
      force uut.u_counter.counter = 32'h0010_00000 - 5;
      @(posedge i_clock);
      release uut.u_counter.counter;
      i_sw[0] = 1'b1;
      repeat (7) @(posedge i_clock);
      assert (uut.u_counter.counter == 0) $display("Limit 0 wrap check pass");
      else $error("Limit 0 wrap check fail");
    end
  endtask

  initial begin
    $dumpfile("sim_output.vcd");
    $dumpvars(0, tb_top_led);
    i_sw = '0;

    $display("--- Running Main Test Suite ---");

    test_reset();
    test_clock();
    test_limit();

    $display("--- All Tests Completed ---");
    $finish;
  end

  //---------------------------------------------------------
  // TODO #4: Automated Check / Assertion (Bonus Challenge)
  // Implement a check that verifies that when i_sw[3] is 1:
  //   - o_led_b is 4'b1111
  //   - o_led_g is 4'b0000
  // And when i_sw[3] is 0:
  //   - o_led_b is 4'b0000
  //   - o_led_g is 4'b1111
  //---------------------------------------------------------

endmodule
