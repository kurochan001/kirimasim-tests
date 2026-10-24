/*
:name: test_implicit_port_expression_nets
:description: A name that appears only in a port expression and a port declaration becomes a net of the default net type with the width of the port declaration (IEEE 1800-2023 Section 6.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.10 23.2.2.1 22.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_port_expression_nets.expected
*/
// IEEE 1800-2023 §6.10: an identifier used in a port expression without a
// net or variable declaration declares an implicit net of the default net
// type, with the vector width of its port declaration (23.2.2.1). The default
// net type is wand here (22.8).
// In the child, a and y have 4-bit port declarations and s a 1-bit one, and
// none of them has a net declaration, so a and y are 4-bit wand nets and s is
// a scalar one. y has two drivers, a = 4'b1101 and 4'b0110, which a wand
// resolves bit by bit to 4'b0100; the parent sees the same value on cy.
// Oracle checks: Icarus Verilog 13.0 makes y a wire, so it resolves the two
// drivers to x1xx; the 5.052 release does not support a default net type
// other than wire or none.

`default_nettype wand

module test_implicit_port_expression_nets_child(a, y, s);
  input [3:0] a;
  output [3:0] y;
  input s;
  assign y = a;
  assign y = 4'b0110;
  initial #1 $display("child: bits a=%0d y=%0d s=%0d, y=%b", $bits(a), $bits(y), $bits(s), y);
endmodule

module test_implicit_port_expression_nets;
  logic [3:0] src = 4'b1101;
  wire [3:0] cy;

  test_implicit_port_expression_nets_child c(src, cy, 1'b1);

  initial #2 $display("parent: cy=%b", cy);
endmodule

`default_nettype wire
