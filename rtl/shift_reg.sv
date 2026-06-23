`timescale 1ps / 1ps

module shift_reg #(
    parameter NB_SHIFT_REG = 4
) (
    output wire [NB_SHIFT_REG - 1 : 0] o_led_enable,
    input  wire                        i_shift,
    input  wire                        i_reset,
    input  wire                        i_clock
);

  reg [NB_SHIFT_REG - 1 : 0] shift_register;

  always @(posedge i_clock or negedge i_reset) begin
    if (!i_reset) begin
      shift_register <= {1'b1, {(NB_SHIFT_REG - 1) {1'b0}}};
    end else if (i_shift) begin
      shift_register <= {shift_register[0], shift_register[NB_SHIFT_REG-1:1]};
    end
  end

  assign o_led_enable = shift_register;

endmodule
