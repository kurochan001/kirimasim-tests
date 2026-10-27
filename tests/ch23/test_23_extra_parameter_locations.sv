/*
:name: test_23_extra_parameter_locations
:description: Value parameters may be declared in a parameter port list or as module items; when a parameter port list exists, an additional body parameter is local and keeps its default (IEEE 1800-2023 Section 23.10)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10 6.20.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_parameter_locations.expected
*/
// IEEE 1800-2023 §23.10: the overridable value and type parameters of a
// module can be declared in its parameter port list or as module items.
// If a module has a parameter port list, any additional parameter declared
// as a module item is treated as a local parameter (§6.20.1), so it cannot
// be given an instance parameter value and keeps the value of its
// declaration.
// pl_body has the port-list parameter A and the body parameter B, which is
// therefore local. The instance sets A to 5 by name, and B stays 2; the
// local parameter C is computed from the final A and B as 7.
// pl_items has no parameter port list, so its two body parameters P and Q
// are overridable; the ordered assignment #(11, 22) gives them 11 and 22.
// The two displays use different delays, so their order is fixed.

module pl_body #(parameter int A = 1) ();
  parameter int B = 2;
  localparam int C = A + B;

  initial #1 $display("A=%0d B=%0d C=%0d", A, B, C);
endmodule

module pl_items;
  parameter int P = 10;
  parameter int Q = 20;

  initial #2 $display("P=%0d Q=%0d", P, Q);
endmodule

module test_23_extra_parameter_locations;
  pl_body #(.A(5)) u();
  pl_items #(11, 22) v();

  initial #3 $finish;
endmodule
