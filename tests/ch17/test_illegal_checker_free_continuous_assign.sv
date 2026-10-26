/*
:name: test_illegal_checker_free_continuous_assign
:description: A continuous assignment cannot drive a free checker variable (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker drives its free variable x with a continuous assignment
:expected_stderr_regex: test_illegal_checker_free_continuous_assign\.sv:(26|34):
*/
// IEEE 1800-2023 §17.7.1: a continuous assignment to a free checker variable
// is illegal; a nonblocking assignment in an always_ff procedure is allowed.
// The checker declares rand bit x and drives x with a continuous assignment,
// so the design is illegal. The continuous assignment to the non-free output
// o, which reads x, is legal. Icarus Verilog 13.0 has no checkers and the
// 5.052 release rejects rand checker variables, so the expected rejection
// follows the clause alone.

`timescale 1ns/1ns

checker cb_free_cont (input logic a, output bit o);
  rand bit x;
  assign x = ~a;   // illegal: continuous assignment to a free variable
  assign o = x;
endchecker : cb_free_cont

module test_illegal_checker_free_continuous_assign;
  logic a = 1'b1;
  bit o;

  cb_free_cont u_cb (.a(a), .o(o));

  initial #1 $finish;
endmodule
