/*
:name: test_illegal_property_disable_iff_local_variable
:description: A disable condition cannot refer to a local variable of the property (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the disable condition of p_loc refers to the local variable v
:expected_stderr_regex: test_illegal_property_disable_iff_local_variable\.sv:27:
*/
// IEEE 1800-2023 §16.12: the disable condition shall not contain a
// reference to a local variable. v is a local variable of p_loc with an
// initial value, and its disable iff tests v. With a module variable in
// its place the property would be legal.
// Icarus Verilog 13.0 does not support concurrent assertions, so the errors
// it reports here do not count.

module test_illegal_property_disable_iff_local_variable;
  logic clk, clk2, a, b, r1, r2;
  int d, k;

  property p_loc;
    int v = 0;
    @(posedge clk) disable iff (v != 0) a |=> b;   // illegal: local variable
  endproperty

  a_loc: assert property (p_loc);
endmodule
