/*
:name: test_event_method_unrelated_member_observation
:description: Record event method reevaluation when referenced and unrelated members change
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_event_method_unrelated_member_observation.expected
*/
`timescale 1ns/1ns
module test_event_method_unrelated_member_observation;
  class tracker;
    int used = 0;
    int unused = 0;

    function int sample();
      if ($test$plusargs("observe_evaluations"))
        $display("evaluated t=%0d value=%0d", $time, used);
      return used;
    endfunction
  endclass

  tracker state;
  int wakes = 0;

  initial begin
    state = new();
    #2;
    if (!$test$plusargs("omit_unused"))
      state.unused = 1;
    #1 $display("after unrelated write=%0d", wakes);
    #1 state.used = 1;
    #1 $display("after referenced write=%0d", wakes);
    #1;
    if (!$test$plusargs("omit_unused"))
      state.unused = 2;
    #1 $display("after second unrelated write=%0d", wakes);
    #1 state.used = 2;
    #1 $display("after second referenced write=%0d", wakes);
    $finish(0);
  end

  initial begin
    #1;
    forever @(state.sample())
      wakes++;
  end
endmodule
