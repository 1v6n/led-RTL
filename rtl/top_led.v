`timescale 1ns / 1ps

module top_led #(
    parameter N_SWITCH = 4,
    parameter N_LED = 4
) (
    output wire [N_LED - 1 : 0] o_led,
    output wire [N_LED - 1 : 0] o_led_b,
    output wire [N_LED - 1 : 0] o_led_g,
    input wire [N_SWITCH-1:0] i_sw,
    input wire i_reset,
    input wire clock
);

  wire shift;
  wire [N_LED-1:0] led_enable;

  counter u_counter (
      .o_shift(shift),
      .i_enable(i_sw[0]),
      .i_sel_count_limit(i_sw[2:1]),
      .i_reset(i_reset),
      .clock(clock)
  );

  shift_reg u_shift_reg (
      .o_led_enable(led_enable),
      .i_shift(shift),
      .i_reset(i_reset),
      .clock(clock)
  );

  assign o_led   = led_enable;
  assign o_led_b = (i_sw[3]) ? 4'b1111 : 4'b0000;
  assign o_led_g = 4'b0000;

endmodule
