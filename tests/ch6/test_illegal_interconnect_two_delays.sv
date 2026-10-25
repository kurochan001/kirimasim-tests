/*
:name: test_illegal_interconnect_two_delays
:description: An interconnect net declaration can specify one delay value but not two (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 6.6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declaration of the interconnect net n specifies two delay values
:expected_stderr_regex: test_illegal_interconnect_two_delays\.sv:33:
*/
// IEEE 1800-2023 §6.7.1: an interconnect net declaration shall specify at
// most one delay value. The first declaration, with the single delay #2, is
// legal; the second gives n the two delays of #(2, 3).
// Both interconnect nets connect the output of one child to the input of
// another, so each becomes a net of the type of those ports (23.3.3.7.1) and
// nothing else in the design is in error.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release do not support
// interconnect and report an error at every interconnect declaration, this
// line among them, so the runner sees a match that does not count.

module test_illegal_interconnect_two_delays_src (output wire logic o);
  assign o = 1'b1;
endmodule

module test_illegal_interconnect_two_delays_dst (input wire logic i);
endmodule

module test_illegal_interconnect_two_delays;
  interconnect #2 ok;
  interconnect #(2, 3) n;   // illegal: two delay values
  test_illegal_interconnect_two_delays_src s1(.o(ok));
  test_illegal_interconnect_two_delays_dst d1(.i(ok));
  test_illegal_interconnect_two_delays_src s2(.o(n));
  test_illegal_interconnect_two_delays_dst d2(.i(n));
endmodule
