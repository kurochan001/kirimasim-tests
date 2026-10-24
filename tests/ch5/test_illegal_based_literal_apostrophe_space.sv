/*
:name: test_illegal_based_literal_apostrophe_space
:description: White space between the apostrophe and the base letter of a based literal is rejected (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7.1 5.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the apostrophe of the based literal is separated from its base letter h by a space
:expected_stderr_regex: test_illegal_based_literal_apostrophe_space\.sv:26:
*/
// IEEE 1800-2023 §5.7.1: the apostrophe and the base format character of a
// based literal shall not be separated by white space, and footnote 38 of
// Syntax 5-2 (§5.7) makes embedded spaces in a base designator illegal.
// White space is allowed between the size and the base and between the base
// and the value, as in 8 'h A5, which is legal; on the marked line the space
// is between ' and h, an error.

module test_illegal_based_literal_apostrophe_space;
  logic [7:0] a, b;

  initial begin
    a = 8 'h A5;
    b = 8' hA5;   // illegal: white space between ' and the base letter
    $display("%h %h", a, b);
  end
endmodule
