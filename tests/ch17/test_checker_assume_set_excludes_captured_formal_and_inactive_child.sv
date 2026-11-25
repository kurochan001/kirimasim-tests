/*
:name: test_checker_assume_set_excludes_captured_formal_and_inactive_child
:description: Checker assume clocks depend on active actuals and exclude const casts
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_assume_set_excludes_captured_formal_and_inactive_child
:expected_stdout: @test_checker_assume_set_excludes_captured_formal_and_inactive_child.expected
*/
`timescale 1ns/1ns

checker use_actual(input bit clock, input bit [31:0] value, input int id);
  observed: assume property (@(posedge clock) value[0])
    $display("child %0d checked t=%0d", id, $time);
  else
    $display("child %0d checked t=%0d", id, $time);
endchecker

checker with_nested_assumptions(input bit own_clock, child_clock, inactive_clock,
                                capture_clock, write_clock, captured,
                                output bit [31:0] observed);
  rand bit [31:0] active_value;
  rand bit [31:0] inactive_value = 32'h524f91c3;
  always_ff @(posedge write_clock) inactive_value <= inactive_value + 1;
  assign observed = active_value;

  own: assume property (@(posedge own_clock) active_value[0])
    $display("own assumption checked t=%0d", $time);
  else
    $display("own assumption checked t=%0d", $time);

  // Only the first child references an active free variable of this instance.
  use_actual included(child_clock, active_value ^ inactive_value, 1);
  use_actual excluded(inactive_clock, inactive_value, 2);

  // This property is checked in simulation, but the actual of captured
  // contains a const cast, so its event does not clock this assume set.
  with_capture: assume property (@(posedge capture_clock)
    active_value[1] == captured)
    $display("captured assumption checked t=%0d", $time);
  else
    $display("captured assumption checked t=%0d", $time);
endchecker

module test_checker_assume_set_excludes_captured_formal_and_inactive_child;
  bit own_clock, child_clock, inactive_clock, capture_clock, write_clock;
  bit external_value;
  wire [31:0] observed;
  bit [31:0] before_event;

  with_nested_assumptions u(own_clock, child_clock, inactive_clock,
                            capture_clock, write_clock, const'(external_value),
                            observed);

  initial begin
    #5 own_clock = 1;
    #5 child_clock = 1;
    #3 before_event = observed;
    #2 inactive_clock = 1;
    #1 $display("inactive child kept choice=%0d", observed == before_event);
    #2 before_event = observed;
    #2 capture_clock = 1;
    #1 $display("captured actual kept choice=%0d", observed == before_event);
    $finish;
  end
endmodule
