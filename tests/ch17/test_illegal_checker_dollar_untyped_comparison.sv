/*
:name: test_illegal_checker_dollar_untyped_comparison
:description: an untyped checker formal bound to the terminal $ may be the upper bound of a cycle delay range but not an operand of a comparison (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: u_bad passes $ to the untyped formal n of dl_cmp, which the checker also uses as an operand of the comparison v < n
:expected_stderr_regex: test_illegal_checker_dollar_untyped_comparison\.sv:(31|39):
*/
// IEEE 1800-2023 §17.3: the terminal $ may be an actual input argument of a
// checker instance, but then the corresponding formal argument shall be
// untyped, and each reference to it shall be the upper bound of a cycle delay
// range, an actual argument of a sequence, property or checker instance, or a
// default argument of a nested checker. Any other reference is an error.
// The formal n of dl_cmp is untyped. c_range uses it as the upper bound of
// ##[1:n], which is allowed for $, and c_less uses it as an operand of <,
// which is not. u_five passes the constant 5, so both references are legal;
// u_bad passes $, and the reference in c_less is the only error. A tool can
// report it at the instance or at that reference.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release
// of Verilator reports syntax errors at both instances because it does
// not support an event expression as a checker actual, so neither
// counts.

checker dl_cmp(event clk, logic s, logic e, logic [7:0] v, untyped n);
  c_range: cover property (@clk s ##[1:n] e);
  c_less: cover property (@clk v < n);
endchecker : dl_cmp

module test_illegal_checker_dollar_untyped_comparison;
  logic clk = 1'b0, s = 1'b0, e = 1'b0;
  logic [7:0] v = 8'd0;

  dl_cmp u_five(posedge clk, s, e, v, 5);
  dl_cmp u_bad(posedge clk, s, e, v, $);   // illegal
endmodule
