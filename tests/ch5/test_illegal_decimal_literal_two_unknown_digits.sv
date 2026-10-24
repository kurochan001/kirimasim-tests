/*
:name: test_illegal_decimal_literal_two_unknown_digits
:description: A decimal based literal with two unknown digits is rejected (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the decimal literal 8'dxz has two x or z digits
:expected_stderr_regex: test_illegal_decimal_literal_two_unknown_digits\.sv:26:
*/
// IEEE 1800-2023 §5.7.1: in a decimal literal the value token shall not
// contain x, z or ? digits unless it is exactly one such digit, which makes
// every bit x or z (underscores may follow it, Syntax 5-2). 8'dz and 8'd?
// are legal; on the marked line 8'dxz has two unknown digits, an error. The
// test of 8'd1x checks an unknown digit next to an ordinary one.

module test_illegal_decimal_literal_two_unknown_digits;
  logic [7:0] a, b, c;

  initial begin
    a = 8'dz;
    b = 8'd?;
    c = 8'dxz;   // illegal: two unknown digits
    $display("%b %b %b", a, b, c);
  end
endmodule
