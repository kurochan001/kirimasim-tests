/*
:name: test_recrem_allows_both_negative_limit_signs_above_sum_boundary
:description: Either recrem limit may be negative when their sum is two simulation precision units
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.6 31.9
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recrem_allows_both_negative_limit_signs_above_sum_boundary.expected
*/
`timescale 1ns/1ns
module test_recrem_allows_both_negative_limit_signs_above_sum_boundary;
  reg rst_n = 0, clk = 0;
  reg negative_recovery = 0, negative_removal = 0;
  specify
    $recrem(posedge rst_n, posedge clk, -3, 5, negative_recovery);
    $recrem(posedge rst_n, posedge clk, 5, -3, negative_removal);
  endspecify
  initial begin
    #10 rst_n = 1;
    #10 clk = 1;
    #5 $display("recovery=%b removal=%b", negative_recovery, negative_removal);
  end
endmodule
