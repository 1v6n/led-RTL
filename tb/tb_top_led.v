/* verilator lint_off UNUSEDSIGNAL */
`timescale 1ns / 1ps

module tb_top_led;

  reg clock;
  reg i_reset;
  reg [3:0] i_sw;

  wire [3:0] o_led;
  wire [3:0] o_led_b;
  wire [3:0] o_led_g;

  top_led uut (
      .o_led(o_led),
      .o_led_b(o_led_b),
      .o_led_g(o_led_g),
      .i_sw(i_sw),
      .i_reset(i_reset),
      .clock(clock)
  );

  always begin
    #5 clock = ~clock;
  end

  initial begin
    $dumpfile("sim_output.vcd");
    $dumpvars(0, tb_top_led);

    clock = 0;
    i_reset = 0;
    i_sw = 4'b0000;

    #20 i_reset = 1;

    #10 i_sw[0] = 1;

    #500;

    i_sw[2:1] = 2'b01;
    #500;

    i_sw[3] = 1;
    #200;

    $finish;
  end

endmodule
