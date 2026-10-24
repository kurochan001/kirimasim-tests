/*
:name: test_illegal_constant_assignment_pattern_variable_member
:description: every member expression of a constant assignment pattern expression has to be a constant expression (IEEE 1800-2023 Section 10.9)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment pattern that gives the value of the parameter R2 has the variable v as a member expression
:expected_stderr_regex: test_illegal_constant_assignment_pattern_variable_member\.sv:25:
*/
// IEEE 1800-2023 §10.9 (Syntax 10-5, footnote 37): in a constant assignment
// pattern expression, all member expressions shall be constant expressions.
// The value of a parameter is a constant expression. P2 is given a pattern of
// a literal and the local parameter Q, which is legal; the pattern for R2
// contains the variable v.
// Icarus Verilog 13.0 does not support unpacked array parameters.

module test_illegal_constant_assignment_pattern_variable_member;
  localparam int Q = 4;
  int v = 3;
  localparam int P2 [2] = '{1, Q};
  localparam int R2 [2] = '{Q, v};   // illegal: v is not a constant expression

  initial $display("%0d %0d", P2[0], P2[1]);
endmodule
