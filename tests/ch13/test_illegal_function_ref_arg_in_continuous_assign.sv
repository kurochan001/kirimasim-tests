/*
:name: test_illegal_function_ref_arg_in_continuous_assign
:description: a function with a ref formal that is not const cannot be called in a continuous assignment, outside procedural statements, while one with a const ref formal can (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w_bad calls twice_ref, which has the ref formal k
:expected_stderr_regex: test_illegal_function_ref_arg_in_continuous_assign\.sv:39:
*/
// IEEE 1800-2023 13.4: it shall be illegal to call a function with output,
// inout or ref formals in an expression that is not within a procedural
// statement, such as the right side of a continuous assignment; a const ref
// formal is allowed there. twice_cref has a const ref formal, and the
// continuous assignment to w_ok calls it legally. twice_ref has the same
// body with a plain ref formal, and the continuous assignment to w_bad calls
// it. Without that assignment the design prints w_ok=6.
// Icarus Verilog 13.0 does not parse const ref formals. The 5.054 release
// of Verilator reports src as a continuously assigned variable with an
// initial value, at its declaration and not at the call; it runs the design
// without the marked line.

module test_illegal_function_ref_arg_in_continuous_assign;
  int src = 3;
  int w_ok, w_bad;

  function automatic int twice_ref(ref int k);
    return 2 * k;
  endfunction

  function automatic int twice_cref(const ref int k);
    return 2 * k;
  endfunction

  assign w_ok = twice_cref(src);
  assign w_bad = twice_ref(src);   // illegal: ref formal that is not const

  initial #1 $display("w_ok=%0d", w_ok);
endmodule
