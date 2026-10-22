/*
:name: test_interconnect_primitive_broadcast_input
:description: An interconnect can serve as an input to multiple primitive terminals and inherit the connected signal shape (IEEE 1800-2023 Section 23.3.3.7.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.2 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_primitive_broadcast_input.expected
*/
// IEEE 1800-2023 23.3.3.7.2 6.6.8: A module output drives the untyped
// interconnect and scalar primitives consume it without an illegal untyped-net
// diagnostic.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module interconnect_source(output wire y); assign y = 1'b1; endmodule
module test_interconnect_primitive_broadcast_input;
  interconnect connection;
  wire inverted, passed;
  interconnect_source source(connection);
  not first(inverted, connection);
  buf second(passed, connection);
  initial #1 $display("inverted=%b passed=%b", inverted, passed);
endmodule
