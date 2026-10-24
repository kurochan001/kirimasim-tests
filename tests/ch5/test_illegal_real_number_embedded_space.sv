/*
:name: test_illegal_real_number_embedded_space
:description: A space between the mantissa and the exponent of a real number is rejected (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7 5.7.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the real number 1.5e3 is written with a space before its exponent
:expected_stderr_regex: test_illegal_real_number_embedded_space\.sv:26:
*/
// IEEE 1800-2023 §5.7 (Syntax 5-2, footnote 38): embedded spaces are
// illegal in an unsigned number, a real number, the value digits of a
// based literal and its base designator.
// 1.5e3 is a legal real number
// (§5.7.2); on the marked line 1.5 e3 is a real number followed by an
// identifier, an error.

module test_illegal_real_number_embedded_space;
  real a, b;

  initial begin
    a = 1.5e3;
    b = 1.5 e3;   // illegal: a space inside the real number
    $display("%f %f", a, b);
  end
endmodule
