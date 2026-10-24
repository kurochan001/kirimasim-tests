/*
:name: test_illegal_decimal_literal_digit_and_x
:description: A decimal based literal that mixes an ordinary digit with an x digit is rejected (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the decimal literal 8'd1x has an x digit next to the ordinary digit 1
:expected_stderr_regex: test_illegal_decimal_literal_digit_and_x\.sv:26:
*/
// IEEE 1800-2023 §5.7.1: in a decimal literal the value token shall not
// contain x, z or ? digits unless it is exactly one such digit, which makes
// every bit x or z (underscores may follow it, Syntax 5-2). 8'dx and 8'd15
// are legal; on the marked line 8'd1x mixes a digit with x, an error. The
// test of 8'dxz checks two unknown digits.

module test_illegal_decimal_literal_digit_and_x;
  logic [7:0] a, b, c;

  initial begin
    a = 8'dx;
    b = 8'd15;
    c = 8'd1x;   // illegal: an ordinary digit and an x digit
    $display("%b %b %b", a, b, c);
  end
endmodule
