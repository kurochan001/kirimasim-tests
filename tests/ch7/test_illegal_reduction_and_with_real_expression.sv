/*
:name: test_illegal_reduction_and_with_real_expression
:description: with a with clause, a reduction method needs its operation to be defined for the type of the with expression, so and() with a real expression is illegal (IEEE 1800-2023 Section 7.12.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the reduction method and() has a with expression of type real, for which the bitwise AND is not defined
:expected_stderr_regex: test_illegal_reduction_and_with_real_expression\.sv:30:
*/
// IEEE 1800-2023 §7.12.3: when a with clause is given, the arithmetic or
// Boolean operation of the reduction method shall be defined for the type of
// the with expression. The array a is of int, so sum() with a real
// expression is legal (addition is defined for real), and so is and() without
// a with clause; the bitwise AND of and() is not defined for real (§11.4.8),
// which makes the last call illegal.
// Icarus Verilog 13.0 reports a syntax error on all three calls, since it
// does not support these methods; Verilator 5.052 accepts the design.

module test_illegal_reduction_and_with_real_expression;
  int a [3] = '{6, 3, 5};
  real r;
  int y;
  initial begin
    y = a.and();
    r = a.sum with (real'(item));
    r = a.and with (real'(item));   // illegal: & is not defined for real
  end
endmodule
