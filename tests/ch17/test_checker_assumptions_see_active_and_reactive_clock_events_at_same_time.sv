/*
:name: test_checker_assumptions_see_active_and_reactive_clock_events_at_same_time
:description: A checker evaluates assumptions sharing a free variable at Active and Reactive clock events in the same time slot
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.3 17.7.2 4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_assumptions_see_active_and_reactive_clock_events_at_same_time.expected
*/
`timescale 1ns/1ns

checker regional_assumptions(input bit active_clock);
  rand bit shared_choice;
  bit reactive_clock;
  assign reactive_clock = active_clock;

  // Either outcome proves that this clock's assumption was evaluated. No
  // particular solver choice or successful solution is required.
  from_active: assume property (@(posedge active_clock) shared_choice == 0)
    $display("active-clock assumption t=%0d", $time);
  else
    $display("active-clock assumption t=%0d", $time);

  from_reactive: assume property (@(posedge reactive_clock) shared_choice == 1)
    $display("reactive-clock assumption t=%0d", $time);
  else
    $display("reactive-clock assumption t=%0d", $time);
endchecker

module test_checker_assumptions_see_active_and_reactive_clock_events_at_same_time;
  bit clk;
  regional_assumptions probe(clk);

  initial begin
    #5 clk = 1;
    #5 clk = 0;
    #5 clk = 1;
    #1;
    $display("monitor finished t=%0d", $time);
  end
endmodule
