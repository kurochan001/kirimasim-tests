/*
:name: test_illegal_interconnect_charge_strength
:description: An interconnect net declaration cannot specify a charge strength (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.7.1 6.6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declaration of the interconnect net n specifies the charge strength medium
:expected_stderr_regex: test_illegal_interconnect_charge_strength\.sv:33:
*/
// IEEE 1800-2023 §6.7.1: an interconnect net declaration shall not specify a
// charge strength, which only trireg can have (6.7). The first declaration,
// without one, is legal; the second gives n the charge strength medium.
// Both interconnect nets connect the output of one child to the input of
// another, so each becomes a net of the type of those ports (23.3.3.7.1) and
// nothing else in the design is in error.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release do not support
// interconnect and report an error at every interconnect declaration, this
// line among them, so the runner sees a match that does not count.

module test_illegal_interconnect_charge_strength_src (output wire logic o);
  assign o = 1'b1;
endmodule

module test_illegal_interconnect_charge_strength_dst (input wire logic i);
endmodule

module test_illegal_interconnect_charge_strength;
  interconnect ok;
  interconnect (medium) n;   // illegal: a charge strength
  test_illegal_interconnect_charge_strength_src s1(.o(ok));
  test_illegal_interconnect_charge_strength_dst d1(.i(ok));
  test_illegal_interconnect_charge_strength_src s2(.o(n));
  test_illegal_interconnect_charge_strength_dst d2(.i(n));
endmodule
