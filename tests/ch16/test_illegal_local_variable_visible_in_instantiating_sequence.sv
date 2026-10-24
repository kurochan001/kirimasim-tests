/*
:name: test_illegal_local_variable_visible_in_instantiating_sequence
:description: a local variable of a sequence is not visible where the sequence is instantiated (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sequence s_outer references v, a local variable of the sequence s_inner that it instantiates
:expected_stderr_regex: test_illegal_local_variable_visible_in_instantiating_sequence\.sv:29:
*/
// IEEE 1800-2023 §16.10: the local variables declared in a sequence or
// property are not visible in the context where it is instantiated. s_inner
// declares and uses v; s_outer instantiates s_inner and then references v,
// which is not declared in s_outer or in the module.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_local_variable_visible_in_instantiating_sequence;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  sequence s_inner;
    int v;
    (a, v = d) ##1 (c == v);
  endsequence
  sequence s_outer;
    s_inner ##1 (b == v);   // illegal
  endsequence
  a_inner: assert property (@(posedge clk) s_inner);
  a_outer: assert property (@(posedge clk) s_outer);
endmodule
