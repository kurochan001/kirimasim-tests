/*
:name: test_illegal_property_local_inout_formal
:description: a local variable formal argument of a named property cannot have direction inout (IEEE 1800-2023 Section 16.12.19)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.19 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a local variable formal argument of a property is declared with direction inout
:expected_stderr_regex: test_illegal_property_local_inout_formal\.sv:26:
*/
// IEEE 1800-2023 §16.12.19: the rules of §16.8.2 for local variable formal
// arguments apply to named properties, except that such a formal of a
// property shall have direction input, written or inferred; declaring one
// with direction inout or output is illegal. A sequence may have such an
// inout formal (§16.8.2); the property p_io declares one.
// Icarus Verilog 13.0 does not support property declarations, and the 5.052
// release of Verilator does not support local formal arguments of properties;
// both reject the line for that reason, so their errors do not count.

module test_illegal_property_local_inout_formal;
  logic clk = 0, a = 0, b = 0;

  property p_io(local inout int v);  // illegal
    (a, v = v + 1) ##1 b;
  endproperty
endmodule
