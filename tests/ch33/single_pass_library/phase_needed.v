`timescale 1ns/1ns
module phase_needed #(parameter [7:0] VALUE=0) (output wire [7:0] value);
  assign value = VALUE;
endmodule
