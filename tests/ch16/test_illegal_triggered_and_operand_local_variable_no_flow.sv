/*
:name: test_illegal_triggered_and_operand_local_variable_no_flow
:description: a local variable passed to a sequence instance to which triggered is applied does not flow out when the triggered application is an operand of &&, so reading it afterwards before a new assignment is an error (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: in s_bad the local variable v is passed to sub only through sub(v).triggered && f, where the application of triggered is an operand of && and not a maximal Boolean expression, so v does not flow out of it and the comparison e == v reads v while it is unassigned
:expected_stderr_regex: test_illegal_triggered_and_operand_local_variable_no_flow\.sv:(50|54):
*/
// IEEE 1800-2023 §16.10: a local variable passed as an entire actual argument
// to an instance of a named sequence to which triggered is applied flows out
// of that application only when it flows out of the end of the instance and
// the application is a maximal Boolean expression: no negation or any other
// expression operator may be applied to it. A local variable that does not
// flow out of a subsequence becomes unassigned at its end, and it shall not
// be referenced until it is assigned again.
// sub assigns its untyped formal lv before it reads it, so v flows out of the
// end of each instance. In s_ok the application of triggered is a whole
// Boolean expression and f is a separate one joined to it by ##0, so v flows
// out and e == v is legal. In s_again the application is an operand of &&,
// but v is assigned again before e == v reads it. In s_bad the application is
// an operand of && and e == v reads v with no assignment after it, which is
// the only error. A tool can report it at the reference or at the cover
// statement of s_bad.
// Icarus Verilog 13.0 does not support sequence declarations and the 5.054
// release of Verilator does not support clocking events in them; both report
// syntax errors on the legal sequences too, so neither error counts.

module test_illegal_triggered_and_operand_local_variable_no_flow;
  logic clk = 0, a = 0, b = 0, c = 0, f = 0;
  int d = 0, e = 0;
  sequence sub(lv);
    @(posedge clk) (a, lv = d) ##1 (b && lv > 0);
  endsequence
  sequence s_ok;
    int v;
    @(posedge clk) c ##1 sub(v).triggered ##0 f ##1 (e == v);
  endsequence
  sequence s_again;
    int v;
    @(posedge clk) c ##1 (sub(v).triggered && f) ##1 (1'b1, v = d) ##1 (e == v);
  endsequence
  sequence s_bad;
    int v;
    @(posedge clk) c ##1 (sub(v).triggered && f)
      ##1 (e == v);   // illegal
  endsequence
  c_ok: cover sequence (s_ok);
  c_again: cover sequence (s_again);
  c_bad: cover sequence (s_bad);
endmodule
