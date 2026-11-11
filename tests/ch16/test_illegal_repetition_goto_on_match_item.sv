/*
:name: test_illegal_repetition_goto_on_match_item
:description: goto repetition cannot be applied to a Boolean expression with a sequence match item (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the goto repetition in p_bad is applied to (b, k = k + 1), a Boolean expression with an attached sequence match item
:expected_stderr_regex: test_illegal_repetition_goto_on_match_item\.sv:31:
*/
// IEEE 1800-2023 §16.9.2: consecutive repetition can be applied to any
// sequence expression, but goto and nonconsecutive repetition only to a
// Boolean expression, and not to one with an attached sequence match
// item.
// p_ok applies consecutive repetition to (b, k = k + 1), which is legal;
// p_bad applies goto repetition to it.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_repetition_goto_on_match_item;
  logic clk = 0, a = 0, b = 0, c = 0;
  property p_ok;
    int k;
    (c, k = 0) ##1 (b, k = k + 1)[*2] |-> k == 2;
  endproperty
  property p_bad;
    int k;
    (c, k = 0) ##1 (b, k = k + 1)[->2] |-> k == 2;   // illegal
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
