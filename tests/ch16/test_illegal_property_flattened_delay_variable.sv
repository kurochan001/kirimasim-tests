/*
:name: test_illegal_property_flattened_delay_variable
:description: An instance of a property whose flattened body is illegal is an error, here a variable as a cycle delay (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: flattening p_dly(k) puts the variable k in the cycle delay ##n
:expected_stderr_regex: test_illegal_property_flattened_delay_variable\.sv:(29|32):
*/
// IEEE 1800-2023 §16.12: an instance of a nonrecursive named property means
// the property obtained by putting the actuals in place of the formals
// (F.4.1); if that property is illegal, the instance is an error. p_dly
// uses its untyped formal n as a cycle delay, and the instance passes the
// module variable k, which is not an elaboration-time constant (§16.7).
// p_dly(2) would be legal. A tool can report the error at the instance or
// at the delay.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_property_flattened_delay_variable;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_dly(n);
    a ##n b;   // illegal: ##(k) after flattening
  endproperty

  c_dly: cover property (@(posedge clk) p_dly(k));   // illegal: k is a variable
endmodule
