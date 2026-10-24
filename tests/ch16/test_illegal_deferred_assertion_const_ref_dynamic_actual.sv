/*
:name: test_illegal_deferred_assertion_const_ref_dynamic_actual
:description: an element of a dynamic array cannot be passed to a const ref argument of the subroutine of a deferred assertion (IEEE 1800-2023 Section 16.4)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pass action of d2 passes the dynamic array element d[1] to the const ref argument of peek
:expected_stderr_regex: test_illegal_deferred_assertion_const_ref_dynamic_actual\.sv:37:
*/
// IEEE 1800-2023 §16.4: it shall be an error to pass automatic or dynamic
// variables as actuals to a ref or const ref formal of the subroutine in an
// action of a deferred assertion. An element of a dynamic array is such a
// dynamic variable. d0 passes the static variable s to the const ref
// argument, and d1 passes d[0] by value; d2 passes d[1] to the const ref
// argument.
// Icarus Verilog 13.0 does not support deferred assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_deferred_assertion_const_ref_dynamic_actual;
  logic a = 1;
  int s = 1;
  int d[];
  function automatic void peek(const ref int x);
    $display("const ref %0d", x);
  endfunction
  function automatic void peek_in(input int v);
    $display("in %0d", v);
  endfunction
  initial begin
    d = new[2];
    d0: assert #0 (a) peek(s);
    d1: assert #0 (a) peek_in(d[0]);
    d2: assert #0 (a) peek(d[1]);   // illegal
  end
endmodule
