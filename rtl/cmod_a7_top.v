`timescale 1ns / 1ps

module cmod_a7_top (
    input wire sysclk,
    output wire [1:0] led,
    output wire led0_b,
    output wire led0_g,
    output wire led0_r
);

  wire [3:0] virtual_sw;
  wire virtual_reset;
  wire [3:0] virtual_reset_bus;
  wire [3:0] virtual_spare_out;
  wire [3:0] led_out;
  wire [3:0] led_b_out;
  wire [3:0] led_g_out;

  assign virtual_reset = virtual_reset_bus[0];

  top_led #(
      .N_SWITCH(4),
      .N_LED(4)
  ) u_top_led (
      .clock(sysclk),
      .i_reset(virtual_reset),
      .i_sw(virtual_sw),
      .o_led(led_out),
      .o_led_b(led_b_out),
      .o_led_g(led_g_out)
  );

  assign led[0] = led_out[0];
  assign led[1] = led_out[1];
  assign led0_b = led_b_out[0];
  assign led0_g = led_g_out[0];
  assign led0_r = 1'b0; 
 
  VIO u_vio (
      .clk_0(sysclk),
      .probe_in0_0(led_out),           
      .probe_in1_0(led_b_out),         
      .probe_in2_0(led_g_out),         
      .probe_out0_0(virtual_sw),       
      .probe_out1_0(virtual_reset_bus),
      .probe_out2_0(virtual_spare_out) 
  );


  ILA u_ila (
      .clk_0(sysclk),
      .probe0_0(led_out) 
  );

endmodule
