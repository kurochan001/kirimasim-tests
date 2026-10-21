/*
:name: test_illegal_property_local_output_formal
:description: a local variable formal argument of a named property cannot have direction output (IEEE 1800-2023 Section 16.12.19)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.19 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a local variable formal argument of a property is declared with direction output
:expected_stderr_regex: test_illegal_property_local_output_formal\.sv:27:
*/
// IEEE 1800-2023 §16.12.19: the rules of §16.8.2 for local variable formal
// arguments of sequences apply to properties, but a local variable formal
// argument of a named property has direction input; declaring one with
// direction inout or output is illegal. A sequence may have such an output
// formal; the property p_out declares one. Icarus Verilog 13.0 does not support
// property declarations, so its syntax error does not count. With Verilator
// 5.052 the first error is that it does not support local formal arguments of
// properties, reported before its syntax error at output, so its rejection does
// not count either.

module test_illegal_property_local_output_formal;
  logic clk = 0, a = 0, b = 0;

  property p_out(local output int v);  // illegal
    (a, v = 1) ##1 b;
  endproperty
endmodule
