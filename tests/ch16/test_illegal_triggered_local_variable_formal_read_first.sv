/*
:name: test_illegal_triggered_local_variable_formal_read_first
:description: in a sequence to which triggered is applied, the formal bound to a local variable cannot be referenced before it is assigned (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: s_bad, instantiated with triggered and the local variable v as actual, references its formal lv before assigning it
:expected_stderr_regex: test_illegal_triggered_local_variable_formal_read_first\.sv:(33|41):
*/
// IEEE 1800-2023 §16.10: a local variable may be passed into an instance of a
// named sequence to which triggered is applied only as an entire actual
// argument, not as a proper subexpression of one, and in the declaration of
// that sequence the formal bound to it shall not be referenced before it is
// assigned.
// s_sub assigns its formal lv and then references it, and p_ok passes the
// local variable v to it; s_bad references lv first, and p_bad passes v to
// it with triggered. A tool can report the error in s_bad or at the
// instance.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 does not support triggered on these instances; neither error counts.

module test_illegal_triggered_local_variable_formal_read_first;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  sequence s_sub(lv);
    @(posedge clk) (a, lv = d) ##1 (c == lv);
  endsequence
  sequence s_bad(lv);
    @(posedge clk) (c == lv) ##1 (a, lv = d);   // illegal
  endsequence
  property p_ok;
    int v;
    @(posedge clk) b ##1 s_sub(v).triggered ##1 (c == v);
  endproperty
  property p_bad;
    int v;
    @(posedge clk) b ##1 s_bad(v).triggered;
  endproperty
  a_ok: assert property (p_ok);
  a_bad: assert property (p_bad);
endmodule
