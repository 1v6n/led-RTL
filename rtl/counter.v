`timescale 1ps / 1ps

module counter #(
    parameter NB_COUNT_LIMIT = 2,
    parameter NB_COUNTER     = 32,
    parameter LIMIT_0        = 32'h0010_00000,
    parameter LIMIT_1        = 32'h0020_00000,
    parameter LIMIT_2        = 32'h0040_00000,
    parameter LIMIT_3        = 32'h0080_00000
) (
    output wire                      o_shift,
    input  wire                      i_enable,
    input  wire [NB_COUNT_LIMIT-1:0] i_sel_count_limit,
    input  wire                      i_reset,
    input  wire                      i_clock
);

  reg  [NB_COUNTER-1:0] counter;
  wire [NB_COUNTER-1:0] counter_next;

  assign counter_next = (i_sel_count_limit == 2'b00 && counter >= LIMIT_0) ? 'd0:
                        (i_sel_count_limit == 2'b01 && counter >= LIMIT_1) ? 'd0:
                        (i_sel_count_limit == 2'b10 && counter >= LIMIT_2) ? 'd0:
                        (i_sel_count_limit == 2'b11 && counter >= LIMIT_3) ? 'd0:
                                                                                counter + 1'b1;

  always @(posedge i_clock or negedge i_reset) begin
    if (!i_reset) begin
      counter <= '0;
    end else if (~i_enable) begin
      counter <= counter;
    end else begin
      counter <= counter_next;
    end
  end

  assign o_shift = (counter == '0) && i_enable;

endmodule
