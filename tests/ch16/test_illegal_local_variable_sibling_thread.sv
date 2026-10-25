/*
:name: test_illegal_local_variable_sibling_thread
:description: a local variable assigned in one operand of and cannot be referenced in the other operand (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the right operand of and in p_bad references x, which only its left operand assigns
:expected_stderr_regex: test_illegal_local_variable_sibling_thread\.sv:(32|35):
*/
// IEEE 1800-2023 §16.10 and F.5.4: a local variable assigned in one of the
// parallel threads of an and, or or intersect cannot be referenced in a
// sibling thread. p_ok assigns x before the and and references it in both
// operands; in p_bad only the left operand assigns x, and the right operand
// references it.
// A tool can report the error in p_bad or at its assertion a_bad.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_sibling_thread;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int x;
    (a, x = d) ##1 ((b ##1 c == x) and (c ##1 b == x));
  endproperty
  property p_bad;
    int x;
    a ##1 (((b, x = d) ##1 c) and (c ##1 (b == x)));   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
