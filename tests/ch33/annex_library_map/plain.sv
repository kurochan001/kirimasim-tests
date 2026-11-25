`timescale 1ns/1ns
module annex_plain(output wire [7:0] value);
  localparam int MARKER = 13;
  assign value = 8'(MARKER);
endmodule
