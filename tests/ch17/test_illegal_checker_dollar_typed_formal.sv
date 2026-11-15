/*
:name: test_illegal_checker_dollar_typed_formal
:description: the terminal $ cannot be the actual argument of a typed checker formal, even when the formal is used only as the upper bound of a cycle delay range (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u_bad passes $ to the formal n of dl_typed, which has the type int
:expected_stderr_regex: test_illegal_checker_dollar_typed_formal\.sv:(29|37):
*/
// IEEE 1800-2023 §17.3: the terminal $ may be an actual input argument of a
// checker instance, but then the corresponding formal argument shall be
// untyped, and each reference to it shall be the upper bound of a cycle delay
// range or an actual argument of an instance.
// The formal n of dl_typed has the type int and is referenced only as the
// upper bound of ##[1:n], a place where a typed formal of type int may stand
// (16.8.1) and where a formal bound to $ may stand. u_three passes the
// constant 3 and is legal; u_bad passes $, so the only rule it breaks is that
// the formal has to be untyped. A tool can report the error at the instance
// or at the declaration of n.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release
// of Verilator reports syntax errors at both instances because it does
// not support an event expression as a checker actual, so neither
// counts.

checker dl_typed(event clk, logic s, logic e, int n);
  c_range: cover property (@clk s ##[1:n] e);
endchecker : dl_typed

module test_illegal_checker_dollar_typed_formal;
  logic clk = 1'b0, s = 1'b0, e = 1'b0;

  dl_typed u_three(posedge clk, s, e, 3);
  dl_typed u_bad(posedge clk, s, e, $);   // illegal
endmodule
