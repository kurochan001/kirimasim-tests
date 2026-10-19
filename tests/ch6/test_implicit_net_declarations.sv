/*
:name: test_implicit_net_declarations
:description: An undeclared name on the left of a continuous assignment, in a port connection or in a primitive terminal list becomes an implicit scalar net (IEEE 1800-2023 Section 6.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.10 22.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_net_declarations.expected
*/
// IEEE 1800-2023 §6.10: a name that has not been declared becomes an implicit
// net of the default net type, wire unless `default_nettype says otherwise
// (22.8), when it appears on the left of a continuous assignment, in the port
// connections of an instance or in the terminal list of a primitive. Such a
// net is a scalar, so a 4-bit output connected to it keeps only its lowest bit.

module implicit_net_leaf(input logic [3:0] d, output logic [3:0] q);
  assign q = d;
endmodule

module test_implicit_net_declarations;
  logic [3:0] src = 4'b0011;

  assign implicit_lhs = src[2];
  implicit_net_leaf u(.d(src), .q(implicit_port));
  buf g(implicit_term, src[3]);

  initial begin
    #1;
    $display("widths: %0d %0d %0d", $bits(implicit_lhs), $bits(implicit_port), $bits(implicit_term));
    $display("values: %b %b %b", implicit_lhs, implicit_port, implicit_term);
  end
endmodule
