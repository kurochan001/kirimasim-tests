/*
:name: test_illegal_property_dollar_typed_formal
:description: The actual $ cannot be bound to a typed formal of a property (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the actual $ is bound to the formal hi of type int
:expected_stderr_regex: test_illegal_property_dollar_typed_formal\.sv:29:
*/
// IEEE 1800-2023 §16.12: if $ is the actual argument of an instance of a
// named property, the corresponding formal shall be untyped. The formal hi
// of p_d has the type int, which a range bound may have, but $ is passed
// to it. With the constant 3 the instance would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_property_dollar_typed_formal;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_d(int hi);
    a ##[1:hi] b;
  endproperty

  c_d: cover property (@(posedge clk) p_d($));   // illegal: $ for a typed formal
endmodule
