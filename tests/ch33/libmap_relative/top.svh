`timescale 1ns/1ns
module relative_top;
  wire [7:0] a, b;
  local_cell at_local(a);
  parent_cell at_parent(b);
  initial #1 $display("current=%0d parent=%0d", a, b);
endmodule
