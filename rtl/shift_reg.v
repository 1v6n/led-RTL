`timescale 1ns / 1ps

module shift_reg #(
    parameter NB_SHIFT_REG = 4
) (
    output wire [NB_SHIFT_REG-1:0] o_led_enable,
    input wire i_shift,
    input wire i_reset,
    input wire clock
);

  reg [NB_SHIFT_REG-1:0] r_shift;

  always @(posedge clock or negedge i_reset) begin
    if (~i_reset) begin
      r_shift <= 'b1;
    end else if (i_shift) begin
      r_shift <= {r_shift[NB_SHIFT_REG-2:0], r_shift[NB_SHIFT_REG-1]};
    end
  end

  assign o_led_enable = r_shift;

endmodule
