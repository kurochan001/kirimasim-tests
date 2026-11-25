`timescale 1ns/1ns
module width_leaf #(parameter int BIAS = 5, WIDTH = 4)(output wire [31:0] value);
  wire [WIDTH-1:0] sized_signal = '1;
  assign value = BIAS * 10 + $bits(sized_signal);
endmodule

module legacy_width_branch(output wire [31:0] value);
  width_leaf leaf(value);
`ifdef CROSS_SOURCE_OVERRIDES
`ifndef OMIT_INNER_OVERRIDE
  defparam leaf.WIDTH = 7;
`endif
`endif
endmodule

module inline_width_branch #(parameter int WIDTH = 4)(output wire [31:0] value);
  width_leaf #(.WIDTH(WIDTH)) leaf(value);
endmodule
