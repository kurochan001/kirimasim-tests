/*
:name: test_inconsistent_negative_limits_clear_numerically_smallest_limit
:description: An inconsistent pair of negative timing limits clears the numerically smaller limit and delays the other reference
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.4 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inconsistent_negative_limits_clear_numerically_smallest_limit.expected
:expected_stderr_regex: (?im)^(?=[^\n]*warning)(?=[^\n]*(?:negative|timing|limit))(?=[^\n]*(?:inconsisten|no[^\n]*solution|unsatisfiable|contradic))[^\n]+
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module test_inconsistent_negative_limits_clear_numerically_smallest_limit;
  bit left_signal, right_signal;
  wire delayed_left, delayed_right;
  time right_rise;
  always @(posedge delayed_right) right_rise = $time;
  specify
    $setuphold(posedge left_signal, posedge right_signal, -4, 8, , , ,
               delayed_left, delayed_right);
    $setuphold(posedge right_signal, posedge left_signal, -2, 6, , , ,
               delayed_right, delayed_left);
  endspecify

  initial begin
    #20 left_signal = 1;
    right_signal = 1;
    #1 $display("early=%b%b", delayed_left, delayed_right);
    #4 $display("late=%b%b right_rise=%0d", delayed_left, delayed_right, right_rise);
  end
endmodule
