/*
:name: test_illegal_based_literal_signed_base_space
:description: White space between the s and the base letter of a signed base designator is rejected (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1 5.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the signed base designator 'sh is written with a space between s and h
:expected_stderr_regex: test_illegal_based_literal_signed_base_space\.sv:26:
*/
// IEEE 1800-2023 §5.7.1: the base format of a based literal is the
// apostrophe, an optional s for a signed literal, and the base letter, with
// no white space between the apostrophe and the base format character;
// footnote 38 of Syntax 5-2 (§5.7) makes embedded spaces in a base
// designator illegal. 8'sh A5 is legal; on the marked line the designator is
// split as 's h, an error.

module test_illegal_based_literal_signed_base_space;
  logic [7:0] a, b;

  initial begin
    a = 8'sh A5;
    b = 8's hA5;   // illegal: white space inside the base designator
    $display("%h %h", a, b);
  end
endmodule
