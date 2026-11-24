/*
:name: test_timing_condition_can_use_explicit_delayed_reference_value
:description: A timecheck condition can be an expression of the delayed reference signal
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.2 31.3.3 31.9.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_condition_can_use_explicit_delayed_reference_value.expected
*/
// The expected results require negative timing checks to be enabled.
`timescale 1ns/1ns
module test_timing_condition_can_use_explicit_delayed_reference_value;
  bit clock, data, guard_clock, guard_data;
  wire delayed_clock, delayed_data;
  wire delayed_guard, delayed_guard_data;
  wire sample_when_reference_high = delayed_guard;
  wire sample_when_reference_low = !delayed_guard;
  reg high_notify = 0, low_notify = 0;

  specify
    $setuphold(posedge guard_clock, posedge guard_data, -8, 12, , , ,
               delayed_guard, delayed_guard_data);
    $setuphold(posedge clock, posedge data, -3, 10, high_notify, ,
               sample_when_reference_high, delayed_clock, delayed_data);
    $setuphold(posedge clock, posedge data, -3, 10, low_notify, ,
               sample_when_reference_low, delayed_clock, delayed_data);
  endspecify

  initial begin
    #20 clock = 1;
    guard_clock = 1;
    #5 $display("condition input: raw=%b delayed=%b", guard_clock, delayed_guard);
    #1 data = 1;
    #4 $display("high=%b low=%b", high_notify, low_notify);
  end
endmodule
