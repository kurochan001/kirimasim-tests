/*
:name: test_illegal_repetition_upper_bound_variable
:description: the upper bound of a repetition range has to be a constant expression or $ (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the upper bound of the nonconsecutive repetition range in p_bad is the variable n
:expected_stderr_regex: test_illegal_repetition_upper_bound_variable\.sv:30:
*/
// IEEE 1800-2023 §16.9.2: the exact count of a repetition and the minimum
// of a repetition range are non-negative integer constant expressions, and
// the maximum of a range is one too or $.
// p_ok uses $, a finite but unbounded maximum, and p_c the parameter C as the
// upper bound of a nonconsecutive repetition range; p_bad uses the module
// variable n.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count. Verilator 5.052 reports this line, and also
// rejects the legal maximum $ of p_ok.

module test_illegal_repetition_upper_bound_variable;
  logic clk = 0, a = 0, b = 0;
  int n = 2;
  localparam int C = 3;
  p_ok: assert property (@(posedge clk) a |-> b[=1:$]);
  p_c: assert property (@(posedge clk) a |-> b[=1:C]);
  p_bad: assert property (@(posedge clk) a |-> b[=1:n]);   // illegal
endmodule
