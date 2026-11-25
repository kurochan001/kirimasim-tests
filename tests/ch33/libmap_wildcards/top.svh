`timescale 1ns/1ns
module wildcard_top;
  wire [7:0] shallow_value, deep_value;
  shallow_cell shallow(shallow_value);
  deep_cell deep(deep_value);
  initial #1 $display("shallow=%0d deep=%0d", shallow_value, deep_value);
endmodule
