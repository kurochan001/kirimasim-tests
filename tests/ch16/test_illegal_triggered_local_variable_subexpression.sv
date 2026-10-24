/*
:name: test_illegal_triggered_local_variable_subexpression
:description: a local variable passed to a sequence instance with triggered has to be an entire actual argument (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the instance of s_rd with triggered in p_bad has the actual v + 1, of which the local variable v is a proper subexpression
:expected_stderr_regex: test_illegal_triggered_local_variable_subexpression\.sv:40:
*/
// IEEE 1800-2023 §16.10: a local variable may be passed into an instance of a
// named sequence to which triggered is applied only as an entire actual
// argument, not as a proper subexpression of one, and in the declaration of
// that sequence the formal bound to it shall not be referenced before it is
// assigned.
// p_ok passes the local variable v as the entire actual of s_sub, whose
// formal lv is assigned before it is referenced. s_rd only reads its
// formal r, and p_bad passes v + 1 to it.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support triggered on these instances; neither error counts.

module test_illegal_triggered_local_variable_subexpression;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  sequence s_sub(lv);
    @(posedge clk) (a, lv = d) ##1 (c == lv);
  endsequence
  sequence s_rd(r);
    @(posedge clk) a ##1 (c == r);
  endsequence
  property p_ok;
    int v;
    @(posedge clk) b ##1 s_sub(v).triggered ##1 (c == v);
  endproperty
  property p_bad;
    int v = 0;
    @(posedge clk) b ##1 s_rd(v + 1).triggered;   // illegal
  endproperty
  a_ok: assert property (p_ok);
  a_bad: assert property (p_bad);
endmodule
