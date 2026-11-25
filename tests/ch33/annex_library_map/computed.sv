`timescale 1ns/1ns
`include "annex_base.svh"
`include "annex_increment.svh"
module annex_computed(output wire [7:0] value);
  localparam int MARKER = `ANNEX_BASE + `ANNEX_INCREMENT;
  assign value = 8'(MARKER);
endmodule
`undef ANNEX_BASE
`undef ANNEX_INCREMENT
