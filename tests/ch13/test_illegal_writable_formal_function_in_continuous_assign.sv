/*
:name: test_illegal_writable_formal_function_in_continuous_assign
:description: A function with an inout formal argument cannot be called in an expression that is not within a procedural statement, such as a continuous assignment (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w_bad calls twice_and_mark, which has the inout formal argument k
:expected_stderr_regex: test_illegal_writable_formal_function_in_continuous_assign\.sv:43:
*/
// IEEE 1800-2023 §13.4: it shall be illegal to call a function with output,
// inout or ref formal arguments in an expression that is not within a
// procedural statement. The right-hand side of a continuous assignment is
// such an expression. twice has an input formal only, and the continuous
// assignment to w_ok calls it, which is legal; twice_and_mark has the inout
// formal k, and the continuous assignment to w_bad calls it with e, a
// variable that nothing else writes. Without that continuous assignment the
// design prints w_ok=10.
// test_illegal_writable_formal_function_in_event_control and
// test_illegal_writable_formal_function_in_force check the other two places.
// Icarus Verilog 13.0 rejects the declaration of twice_and_mark, since it
// takes only input formals in functions, which does not count, and the
// 5.054 release of Verilator accepts the design.

module test_illegal_writable_formal_function_in_continuous_assign;
  int d = 5;
  int e;
  int w_ok, w_bad;

  function int twice(input int k);
    return 2 * k;
  endfunction

  function int twice_and_mark(inout int k);
    k = 1;
    return 2 * k;
  endfunction

  assign w_ok = twice(d);
  assign w_bad = twice_and_mark(e);   // illegal: inout formal outside a procedural statement

  initial #1 $display("w_ok=%0d", w_ok);
endmodule
