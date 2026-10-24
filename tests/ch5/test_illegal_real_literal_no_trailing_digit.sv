/*
:name: test_illegal_real_literal_no_trailing_digit
:description: The real literal 9., which has no digit after its decimal point, is rejected (IEEE 1800-2023 Section 5.7.2)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real literal 9. has no digit after its decimal point
:expected_stderr_regex: test_illegal_real_literal_no_trailing_digit\.sv:25:
*/
// IEEE 1800-2023 §5.7.2: a real number written with a decimal point shall
// have at least one digit on each side of the point, also when an exponent
// follows. 0.12, 9.0, 4.0E3 and 0.2e-7 are legal; the literal on the marked
// line, 9., has no digit after the point, an error. The other tests of
// this rule check .12, 4.E3 and .2e-7.

module test_illegal_real_literal_no_trailing_digit;
  real a, b;

  initial begin
    a = 0.12 + 9.0 + 4.0E3 + 0.2e-7;
    b = 9.;   // illegal: no digit after the point
    $display("%g %g", a, b);
  end
endmodule
