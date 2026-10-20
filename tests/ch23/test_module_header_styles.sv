/*
:name: test_module_header_styles
:description: A module header can be non-ANSI, with parameters and ports declared in the body, or ANSI, with a parameter port list that may hold local parameters derived from the others, a package import and the default lifetime of its subroutines (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.2.1 23.2.3 23.2.4 23.10.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_module_header_styles.expected
*/
// IEEE 1800-2023 §23.2.1: the header of a module names it and gives its ports,
// their direction, size and type, its parameters, its package imports and the
// default lifetime of its subroutines. In the non-ANSI style the port list
// only names the ports and the module items declare them (23.2.4); in the
// ANSI style the header declares them. §23.2.3: port sizes can depend on
// parameters, which each instance can change (23.10.2.2), and a parameter
// port list can hold a local parameter computed from the others. dec is
// automatic, so its recursive function works without the keyword.

package test_module_header_styles_pkg;
  localparam int SHIFT = 1;
endpackage

module test_module_header_styles_old(a, y);
  parameter MSB = 3;
  input [MSB:0] a;
  output [MSB:0] y;
  wire [MSB:0] a;
  logic [MSB:0] y;

  assign y = ~a;
endmodule

module automatic test_module_header_styles_dec
  import test_module_header_styles_pkg::*;
  #(int CODE_BITS = 2, localparam int OUT_BITS = 1 << CODE_BITS)
  (input [CODE_BITS-1:0] code, output logic [OUT_BITS-1:0] onehot, output int depth);

  function int count_down(int n);
    return n == 0 ? 0 : 1 + count_down(n - 1);
  endfunction

  assign onehot = (OUT_BITS)'(1) << code;
  assign depth = count_down(code) << SHIFT;
endmodule

module test_module_header_styles;
  logic [5:0] y6;
  logic [7:0] onehot;
  int depth;

  test_module_header_styles_old #(.MSB(5)) u_old(6'b000101, y6);
  test_module_header_styles_dec #(.CODE_BITS(3)) u_dec(3'd6, onehot, depth);

  initial #1 $display("y6=%b onehot=%b (%0d bits) depth=%0d", y6, onehot, $bits(onehot), depth);
endmodule
