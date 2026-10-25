/*
:name: test_illegal_property_instance_flattened_not_legal
:description: a property instance is legal only if its body with the actuals substituted is legal (IEEE 1800-2023 Section 16.12.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of p_seq in a_bad substitutes the property expression a |-> c for x in x ##1 b, where a sequence is required
:expected_stderr_regex: test_illegal_property_instance_flattened_not_legal\.sv:30:
*/
// IEEE 1800-2023 §16.12.1: an instance of a named property is legal only if
// its body, with the actuals substituted for the formals, is legal where the
// instance stands. p_seq uses its untyped formal x as the operand of the
// concatenation x ##1 b, which needs a sequence. a_ok passes the sequence
// a ##1 c; a_bad passes the property expression a |-> c, which gives
// (a |-> c) ##1 b.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support a sequence as the actual of a property formal;
// neither error counts.

module test_illegal_property_instance_flattened_not_legal;
  logic clk = 0, a = 0, b = 0, c = 0;
  property p_seq(x);
    x ##1 b;
  endproperty
  a_ok: assert property (@(posedge clk) p_seq(a ##1 c));
  a_bad: assert property (@(posedge clk) p_seq(a |-> c));   // illegal
endmodule
