/*
:name: test_illegal_checker_function_side_effect
:description: A function called on the right-hand side of a checker variable assignment shall have no side effects, so an automatic function that increments a package variable is illegal there while one that only reads it is allowed (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment to ys calls the automatic function f_side, which increments the package variable hits
:expected_stderr_regex: test_illegal_checker_function_side_effect\.sv:43:
*/
// IEEE 1800-2023 §17.8: the right-hand side of a checker variable assignment
// may call a function under the restrictions of function calls in concurrent
// assertions (16.6): the function shall be automatic or preserve no state
// information, and have no side effects. f_read is automatic and only reads
// the package variable hits, so the assignment to yr is legal. f_side is
// automatic too but increments hits, a side effect, and the assignment to
// ys calls it. The call is the place of the error: f_side is legal
// elsewhere.
// Without the assignment to ys the design is legal.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator accepts the design; its run then stops because the
// assignments do not settle.

`timescale 1ns/1ns

package fse_pkg;
  int hits = 0;
  function automatic int f_read(int x);
    return x + hits;
  endfunction
  function automatic int f_side(int x);   // has a side effect
    hits++;
    return x;
  endfunction
endpackage : fse_pkg

checker fse_chk(input int a, output int y);
  int yr, ys;
  assign yr = fse_pkg::f_read(a);
  assign ys = fse_pkg::f_side(a);   // illegal: f_side changes hits
  assign y = yr;
endchecker : fse_chk

module test_illegal_checker_function_side_effect;
  int a = 1;
  int y;

  fse_chk c(a, y);

  initial #1 $display("y=%0d", y);
endmodule
