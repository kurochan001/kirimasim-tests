/*
:name: test_illegal_real_literal_exponent_no_leading_digit
:description: The real literal .2e-7, which has no digit before its decimal point, is rejected (IEEE 1800-2023 Section 5.7.2)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real literal .2e-7 has no digit before its decimal point
:expected_stderr_regex: test_illegal_real_literal_exponent_no_leading_digit\.sv:25:
*/
// IEEE 1800-2023 §5.7.2: a real number written with a decimal point shall
// have at least one digit on each side of the point, also when an exponent
// follows. 0.12, 9.0, 4.0E3 and 0.2e-7 are legal; the literal on the marked
// line, .2e-7, has no digit before the point, an error. The other tests of
// this rule check .12, 9. and 4.E3.

module test_illegal_real_literal_exponent_no_leading_digit;
  real a, b;

  initial begin
    a = 0.12 + 9.0 + 4.0E3 + 0.2e-7;
    b = .2e-7;   // illegal: no digit before the point
    $display("%g %g", a, b);
  end
endmodule
