/*
:name: test_illegal_recrem_negative_removal_sum_at_precision
:description: A recrem check with negative removal and a sum of one precision unit is rejected
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.3.6 31.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the sum of the two limits must exceed one precision unit when either is negative
:expected_stderr_regex: test_illegal_recrem_negative_removal_sum_at_precision\.sv:18:(?:\d+:)?[^\n]*(?i:(?:sum|recovery_limit\s*\+\s*removal_limit|recrem)[^\n]*(?:precision|greater|positive))
*/
`timescale 1ns/1ns
module test_illegal_recrem_negative_removal_sum_at_precision;
  reg rst_n = 0, clk = 0;
  specify
    $recrem(posedge rst_n, posedge clk, 4, -3); // illegal
  endspecify
  initial begin
    #10 rst_n = 1;
    #10 clk = 1;
    #1 $display("simulation started");
  end
endmodule
