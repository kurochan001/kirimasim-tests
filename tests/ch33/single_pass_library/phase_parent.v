`timescale 1ns/1ns
module phase_parent(input wire [7:0] stimulus, output wire [7:0] observed);
  wire [7:0] adjusted;
  assign adjusted = stimulus + 8'd2;
  phase_child child(adjusted, observed);
endmodule
