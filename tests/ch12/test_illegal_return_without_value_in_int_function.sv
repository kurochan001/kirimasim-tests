/*
:name: test_illegal_return_without_value_in_int_function
:description: In a function that returns an int, a return statement without an expression is illegal (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a return statement without an expression appears in a function that returns int
:expected_stderr_regex: test_illegal_return_without_value_in_int_function\.sv:20:
*/
// IEEE 1800-2023 §12.8: in a function that returns a value, the return
// statement shall have an expression of the correct type. The first return
// of half() has none; the second one is legal.

module test_illegal_return_without_value_in_int_function;
  function automatic int half(int a);
    if (a < 0) return;   // illegal: no value in a function returning int
    return a / 2;
  endfunction

  initial $display("%0d", half(6));
endmodule
