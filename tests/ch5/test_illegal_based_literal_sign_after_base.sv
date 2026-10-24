/*
:name: test_illegal_based_literal_sign_after_base
:description: A minus sign between the base format and the value of a based literal is rejected (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the minus sign of 8'd-6 stands between the base format and the value digits
:expected_stderr_regex: test_illegal_based_literal_sign_after_base\.sv:24:
*/
// IEEE 1800-2023 §5.7.1: a plus or minus before the size of a based literal
// is a unary operator, so -8'd6 is legal and is the two's complement of
// 8'd6; a sign between the base format and the number is illegal syntax, so
// 8'd-6 on the marked line is an error.

module test_illegal_based_literal_sign_after_base;
  logic [7:0] a, b;

  initial begin
    a = -8'd6;
    b = 8'd-6;   // illegal: a sign after the base format
    $display("%b %b", a, b);
  end
endmodule
