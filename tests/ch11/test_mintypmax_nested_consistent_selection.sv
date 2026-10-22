/*
:name: test_mintypmax_nested_consistent_selection
:description: Nested min typ max expressions apply one consistent selection within arithmetic and delays (IEEE 1800-2023 Section 11.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mintypmax_nested_consistent_selection.expected
*/
// IEEE 1800-2023 11.11: The result is checked without assuming a simulator
// default selection; every legal selection makes the dependent arithmetic and
// elapsed delay agree.

`timescale 1ns/1ns
module test_mintypmax_nested_consistent_selection;
  int base, scaled;
  time start_time;
  initial begin
    base = (2:5:9);
    scaled = 3 * (2:5:9) + 1;
    $display("arithmetic=%0d range=%0d", scaled == 3*base+1,
             base == 2 || base == 5 || base == 9);
    start_time = $time;
    #(4:10:18);
    $display("elapsed=%0d", $time-start_time == 2*base);
  end
endmodule
