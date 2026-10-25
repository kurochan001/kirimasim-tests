/*
:name: test_illegal_property_dollar_outside_bound
:description: An untyped property formal that receives $ can only be used as an upper range bound or as an actual (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the formal x, bound to $, is used as an operand of == instead of as an upper range bound
:expected_stderr_regex: test_illegal_property_dollar_outside_bound\.sv:(27|30):
*/
// IEEE 1800-2023 §16.12: when $ is the actual of an untyped formal of a
// named property, each reference to the formal shall be an upper bound of
// a cycle delay range or an actual of another sequence or property
// instance. p_e uses x in b == x. A tool can report the error at the
// instance or at the reference.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_property_dollar_outside_bound;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_e(x);
    a ##1 (b == x);   // illegal: x is not a range bound
  endproperty

  c_e: cover property (@(posedge clk) p_e($));   // illegal: $ actual
endmodule
