/*
:name: test_illegal_return_wrong_type_in_int_function
:description: In a function that returns an int, a return statement whose expression is a string variable, which cannot be assigned to an int without a cast, is illegal (IEEE 1800-2023 Section 12.8)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.8 6.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a function returning int returns a string variable, which is not of a type that can be returned as int
:expected_stderr_regex: test_illegal_return_wrong_type_in_int_function\.sv:24:
*/
// IEEE 1800-2023 §12.8: in a function that returns a value, the return
// statement shall have an expression of the correct type. A string variable
// cannot be assigned to an integral variable without a cast (6.16), so it is
// not a correct return value of a function returning int. The first return
// of pick() is legal. Verilator 5.052 accepts the design and fails only
// when its generated C++ code is compiled, which does not count here.

module test_illegal_return_wrong_type_in_int_function;
  function automatic int pick(bit which, string text);
    if (which) return 5;
    return text;   // illegal: a string is not an int return value
  endfunction

  initial $display("%0d", pick(1'b1, "7"));
endmodule
