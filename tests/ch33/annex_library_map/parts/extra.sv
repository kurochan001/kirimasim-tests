`timescale 1ns/1ns
module annex_extra(output wire [7:0] value);
  localparam int MARKER = 57;
  assign value = 8'(MARKER);
endmodule
