/*
:name: test_illegal_array_method_with_braces
:description: the with clause of an array manipulation method encloses its expression in parentheses; braces, as used by randomize() with, are illegal there (IEEE 1800-2023 Section 7.12)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with clause of the array method find encloses its expression in braces instead of parentheses
:expected_stderr_regex: test_illegal_array_method_with_braces\.sv:27:
*/
// IEEE 1800-2023 §7.12: an array method call ends with an optional
// with ( expression ); the with clause of an array manipulation method
// takes an expression in parentheses, while the with clause of randomize()
// (§18.7) takes constraints in braces. The first call is legal; the second
// writes the expression in braces.
// Icarus Verilog 13.0 reports a syntax error on both calls, since it does
// not support the with clause of array methods.

module test_illegal_array_method_with_braces;
  int a [4] = '{1, 5, 2, 7};
  int q[$];
  initial begin
    q = a.find with (item > 2);
    q = a.find with { item > 2 };   // illegal: braces instead of parentheses
  end
endmodule
