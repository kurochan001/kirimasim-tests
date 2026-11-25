`timescale 1ns/1ns
module phase_child(input wire [7:0] stimulus, output wire [7:0] observed);
  assign observed = stimulus << 1;
endmodule
