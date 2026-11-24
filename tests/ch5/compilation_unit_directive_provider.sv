`timescale 100ps/10ps
`define COMPILATION_UNIT_DIRECTIVE_MARKER 29
module directive_provider;
  localparam int own_value = `COMPILATION_UNIT_DIRECTIVE_MARKER;
  initial $display("provider marker=%0d", own_value);
endmodule
