/*
:name: test_illegal_interconnect_continuous_assign
:description: An interconnect net that connects two ports cannot be the target of a continuous assignment (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a continuous assignment drives the interconnect net n
:expected_stderr_regex: test_illegal_interconnect_continuous_assign\.sv:34:
*/
// IEEE 1800-2023 §6.6.8: an interconnect net shall not be used in any
// continuous assignment. Here n connects the output of one child to the input
// of another, so the net it becomes has the type of those ports (23.3.3.7.1)
// and the design is legal apart from the continuous assignment to n, which is
// the only error.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release do not support
// interconnect and stop at its declaration, which does not count.

module test_illegal_interconnect_continuous_assign_src (output wire logic o);
  assign o = 1'b1;
endmodule

module test_illegal_interconnect_continuous_assign_dst (input wire logic i);
endmodule

module test_illegal_interconnect_continuous_assign;
  interconnect n;
  test_illegal_interconnect_continuous_assign_src s(.o(n));
  test_illegal_interconnect_continuous_assign_dst d(.i(n));

  assign n = 1'b0;   // illegal: n is an interconnect net
endmodule
