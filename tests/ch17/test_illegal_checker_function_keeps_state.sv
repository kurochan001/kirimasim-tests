/*
:name: test_illegal_checker_function_keeps_state
:description: A function called on the right-hand side of a checker variable assignment has to be automatic or keep no state, so a static function with a static local counter is illegal there while an automatic function and a static function without state are allowed (IEEE 1800-2023 Section 17.8)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the assignment to yc calls the static function f_count, whose static local n keeps a count from call to call
:expected_stderr_regex: test_illegal_checker_function_keeps_state\.sv:48:
*/
// IEEE 1800-2023 §17.8: the right-hand side of a checker variable assignment
// may call a function under the restrictions of function calls in concurrent
// assertions (16.6): the function shall be automatic or preserve no state
// information, and have no side effects. f_auto counts in its local n, which
// is automatic and starts again at each call; f_pure is static but has no
// local state. The assignments to ya and yp are legal. f_count is static, so
// its static local n keeps its value from call to call, and the assignment
// to yc calls it. The call is the place of the error: f_count is legal
// elsewhere. Without the assignment to yc the design is legal.
// Icarus Verilog 13.0 does not support checkers, and the 5.054 release of
// the Verilator simulator accepts the design.

`timescale 1ns/1ns

package fks_pkg;
  function automatic int f_auto(int x);
    int n = 0;
    n = n + 1;
    return x + n;
  endfunction
  function int f_pure(int x);
    return x + 1;
  endfunction
  function int f_count(int x);   // keeps state
    static int n = 0;
    n = n + 1;
    return x + n;
  endfunction
endpackage : fks_pkg

checker fks_chk(input int a, output int y);
  int ya, yp, yc;
  assign ya = fks_pkg::f_auto(a);
  assign yp = fks_pkg::f_pure(a);
  assign yc = fks_pkg::f_count(a);   // illegal: f_count keeps state
  assign y = ya + yp;
endchecker : fks_chk

module test_illegal_checker_function_keeps_state;
  int a = 1;
  int y;

  fks_chk c(a, y);

  initial #1 $display("y=%0d", y);
endmodule
