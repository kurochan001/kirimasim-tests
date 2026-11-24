/*
:name: test_inconsistent_negative_timing_recalculates_after_each_relaxation
:description: Two incompatible negative timing cycles require two limit relaxations before the reference delays are consistent
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.4 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inconsistent_negative_timing_recalculates_after_each_relaxation.expected
:expected_stderr_regex: (?im)^(?=[^\n]*warning)(?=[^\n]*(?:negative|timing|limit))(?=[^\n]*(?:inconsisten|no[^\n]*solution|unsatisfiable|contradic))[^\n]+
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module test_inconsistent_negative_timing_recalculates_after_each_relaxation;
  bit x, y, z;
  wire delayed_x, delayed_y, delayed_z;
  time y_rise;
  always @(posedge delayed_y) y_rise = $time;
  specify
    $setuphold(posedge x, posedge y, -7, 12, , , , delayed_x, delayed_y);
    $setuphold(posedge y, posedge x, -4, 8, , , , delayed_y, delayed_x);
    $setuphold(posedge z, posedge y, -2, 6, , , , delayed_z, delayed_y);
    $setuphold(posedge y, posedge z, -1, 5, , , , delayed_y, delayed_z);
  endspecify
  initial begin
    #20 x = 1;
    y = 1;
    z = 1;
    #1 $display("early x/y/z=%b%b%b", delayed_x, delayed_y, delayed_z);
    #6 $display("late x/y/z=%b%b%b y_rise=%0d", delayed_x, delayed_y, delayed_z, y_rise);
  end
endmodule
