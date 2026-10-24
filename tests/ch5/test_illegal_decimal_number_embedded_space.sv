/*
:name: test_illegal_decimal_number_embedded_space
:description: A space inside the digits of a decimal number is rejected (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the decimal number 1234 is written with a space between its digits
:expected_stderr_regex: test_illegal_decimal_number_embedded_space\.sv:27:
*/
// IEEE 1800-2023 §5.7 (Syntax 5-2, footnote 38): embedded spaces are
// illegal in an unsigned number, a real number, the value digits of a
// based literal and its base designator.
// 12_34 uses an underscore, which is legal (§5.7.1);
// on the marked line 12 34 is two numbers in a row, an error. The other
// tests of this footnote put the space in a based value, a real number and
// a base designator.

module test_illegal_decimal_number_embedded_space;
  int a, b;

  initial begin
    a = 12_34;
    b = 12 34;   // illegal: a space inside the number
    $display("%0d %0d", a, b);
  end
endmodule
