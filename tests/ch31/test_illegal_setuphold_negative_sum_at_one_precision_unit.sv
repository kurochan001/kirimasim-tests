/*
:name: test_illegal_setuphold_negative_sum_at_one_precision_unit
:description: A setuphold limit sum of exactly one simulation precision unit is rejected
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a negative hold limit leaves the sum equal to one precision unit
:expected_stderr_regex: test_illegal_setuphold_negative_sum_at_one_precision_unit\.sv:18:(?:\d+:)?[^\n]*(?i:(?:sum|setup_limit\s*\+\s*hold_limit|setup[^\n]*hold)[^\n]*(?:precision|greater|positive))
*/
`timescale 1ns/1ns
module test_illegal_setuphold_negative_sum_at_one_precision_unit;
  reg clk = 0, data = 0;
  specify
    $setuphold(posedge clk, posedge data, 4, -3); // illegal
  endspecify
  initial begin
    #10 data = 1;
    #4 clk = 1;
    #1 $display("completed");
  end
endmodule
