/*
:name: test_illegal_checker_free_blocking_assign
:description: A blocking procedural assignment cannot write a free checker variable, although a nonblocking assignment may (IEEE 1800-2023 Section 17.7.1)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.7.1 17.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_comb procedure of the checker writes the free variable x with a blocking assignment
:expected_stderr_regex: test_illegal_checker_free_blocking_assign\.sv:(26|34):
*/
// IEEE 1800-2023 §17.7.1: a blocking procedural assignment to a free checker
// variable is illegal, while a nonblocking assignment in an always_ff
// procedure may write one. The checker declares rand bit x and assigns a to x
// with a blocking assignment in always_comb, so the design is illegal. The
// continuous assignment to the non-free output o reads x and is legal.
// Icarus Verilog 13.0 has no checkers and Verilator 5.052 rejects rand
// checker variables, so the expected rejection follows the clause alone.

`timescale 1ns/1ns

checker cb_free_block (input logic a, output bit o);
  rand bit x;
  always_comb x = a;   // illegal: blocking assignment to a free variable
  assign o = x;
endchecker : cb_free_block

module test_illegal_checker_free_blocking_assign;
  logic a = 1'b1;
  bit o;

  cb_free_block u_cb (.a(a), .o(o));

  initial #1 $finish;
endmodule
