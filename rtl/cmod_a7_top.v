`timescale 1ps / 1ps

module cmod_a7_top #(
    parameter NB_PROB = 3,
    parameter NB_LED  = 3

) (
    input  wire       sys_clk,
    output wire [1:0] o_led,
    output wire       o_led0_b,
    output wire       o_led0_g,
    output wire       o_led0_r
);

  wire [NB_PROB-1:0] virtual_sw;
  wire               virtual_reset;
  wire [NB_PROB-1:0] virtual_reset_bus;
  wire [NB_PROB-1:0] virtual_spare_out;
  wire [ NB_LED-1:0] led_out;
  wire [ NB_LED-1:0] led_b_out;
  wire [ NB_LED-1:0] led_g_out;

  assign virtual_reset = virtual_reset_bus[0];

  top_led #(
      .N_SWITCH(4),
      .N_LED   (4)
  ) u_top_led (
      .i_clock(sys_clk),
      .i_reset(virtual_reset),
      .i_sw   (virtual_sw),
      .o_led  (led_out),
      .o_led_b(led_b_out),
      .o_led_g(led_g_out)
  );

  assign o_led[0] = led_out[0];
  assign o_led[1] = led_out[1];
  assign o_led0_b = led_b_out[0];
  assign o_led0_g = led_g_out[0];
  assign o_led0_r = 1'b0;

  VIO u_vio (
      .clk_0       (sys_clk),
      .probe_in0_0 (led_out),
      .probe_in1_0 (led_b_out),
      .probe_in2_0 (led_g_out),
      .probe_out0_0(virtual_sw),
      .probe_out1_0(virtual_reset_bus),
      .probe_out2_0(virtual_spare_out)
  );

  ILA u_ila (
      .clk_0   (sys_clk),
      .probe0_0(led_out)
  );

endmodule
