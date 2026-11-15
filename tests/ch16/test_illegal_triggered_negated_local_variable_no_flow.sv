/*
:name: test_illegal_triggered_negated_local_variable_no_flow
:description: a local variable passed to a sequence instance to which triggered is applied does not flow out when the triggered application is negated, so reading it afterwards before a new assignment is an error (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: in s_bad the local variable v is passed to sub only through the negated application !sub(v).triggered, from which it does not flow, so the comparison e == v reads v while it is unassigned
:expected_stderr_regex: test_illegal_triggered_negated_local_variable_no_flow\.sv:(49|53):
*/
// IEEE 1800-2023 §16.10: a local variable passed as an entire actual argument
// to an instance of a named sequence to which triggered is applied flows out
// of that application only when it flows out of the end of the instance and
// the application is a maximal Boolean expression, with no negation or other
// operator applied to it. A local variable that does not flow out of a
// subsequence becomes unassigned at its end, and it shall not be referenced
// until it is assigned again.
// sub assigns its untyped formal lv before it reads it, so v flows out of the
// end of each instance. In s_ok the application of triggered stands alone, so
// v flows out and e == v is legal. In s_again the negated application leaves
// v unassigned, but v is assigned again before e == v reads it. In s_bad the
// application is negated and e == v reads v with no assignment after it, which
// is the only error. A tool can report it at the reference or at the cover
// statement of s_bad.
// Icarus Verilog 13.0 does not support sequence declarations and the 5.054
// release of Verilator does not support clocking events in them; both report
// syntax errors on the legal sequences too, so neither error counts.

module test_illegal_triggered_negated_local_variable_no_flow;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0, e = 0;
  sequence sub(lv);
    @(posedge clk) (a, lv = d) ##1 (b && lv > 0);
  endsequence
  sequence s_ok;
    int v;
    @(posedge clk) c ##1 sub(v).triggered ##1 (e == v);
  endsequence
  sequence s_again;
    int v;
    @(posedge clk) c ##1 !sub(v).triggered ##1 (1'b1, v = d) ##1 (e == v);
  endsequence
  sequence s_bad;
    int v;
    @(posedge clk) c ##1 !sub(v).triggered
      ##1 (e == v);   // illegal
  endsequence
  c_ok: cover sequence (s_ok);
  c_again: cover sequence (s_again);
  c_bad: cover sequence (s_bad);
endmodule
