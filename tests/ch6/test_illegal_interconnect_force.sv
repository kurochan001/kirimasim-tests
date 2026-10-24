/*
:name: test_illegal_interconnect_force
:description: An interconnect net that connects two ports cannot be the target of a force statement, a procedural continuous assignment (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.8 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure forces the interconnect net n
:expected_stderr_regex: test_illegal_interconnect_force\.sv:34:
*/
// IEEE 1800-2023 §6.6.8: an interconnect net shall not be used in any
// procedural continuous assignment. force is a procedural continuous
// assignment that can have a net as its target (10.6.2), but not an
// interconnect net. Here n connects the output of one child to the input of
// another, which is legal (23.3.3.7.1); the force of n is the only error.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release do not support
// interconnect and stop at its declaration, which does not count.

module test_illegal_interconnect_force_src (output wire logic o);
  assign o = 1'b1;
endmodule

module test_illegal_interconnect_force_dst (input wire logic i);
endmodule

module test_illegal_interconnect_force;
  interconnect n;
  test_illegal_interconnect_force_src s(.o(n));
  test_illegal_interconnect_force_dst d(.i(n));

  initial #1 force n = 1'b0;   // illegal: n is an interconnect net
endmodule
