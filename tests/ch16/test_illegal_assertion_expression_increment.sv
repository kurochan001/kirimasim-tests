/*
:name: test_illegal_assertion_expression_increment
:description: evaluating an expression of a concurrent assertion cannot have a side effect such as the increment operator (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the Boolean expression (cnt++ > 0) in p_bad changes the module variable cnt
:expected_stderr_regex: test_illegal_assertion_expression_increment\.sv:32:
*/
// IEEE 1800-2023 §16.6: only a sequence match item whose variable_lvalue is
// a local variable may use the C assignment, increment and decrement
// operators; otherwise evaluating an expression of an assertion shall have
// no side effects. p_loc increments its local variable k in a match item,
// which is legal; in a Boolean expression, p_bad uses
// the increment operator on the module variable cnt.
// Icarus Verilog 13.0 does not support these assertions, and the 5.052
// release of Verilator stops with an internal error on this line, which does
// not count.

module test_illegal_assertion_expression_increment;
  logic clk = 0, a = 0, b = 0;
  int cnt;
  property p_loc;
    int k;
    (a, k = 0) ##1 (b, k++) |-> k == 1;
  endproperty
  a_loc: assert property (@(posedge clk) p_loc);
  p_bad: assert property (@(posedge clk) a ##1 (cnt++ > 0));   // illegal
endmodule
