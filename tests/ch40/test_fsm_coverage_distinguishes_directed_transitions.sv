/*
:name: test_fsm_coverage_distinguishes_directed_transitions
:description: Two FSM histories with identical visited states cover different directed transitions and repeat different edges
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.2.1 40.2.2 40.4.1 40.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: directed_fsm_report/expected.txt
:expected_stdout: @test_fsm_coverage_distinguishes_directed_transitions.expected
*/
// The bare simulation confirms both state histories. Run
// tools/run_fsm_transition_coverage.py to check the coverage report.
`timescale 1ns/1ns
module directed_fsm #(parameter bit REVERSE = 0);
  /* tool state_vector state enum path_modes */
  logic [1:0] state = 0;
  parameter [1:0] /* tool enum path_modes */ S0 = 0, S1 = 1, S2 = 2;

  initial begin
    #2 state = REVERSE ? S2 : S1;
    #2 state = REVERSE ? S1 : S2;
    #2 state = REVERSE ? S2 : S1;
    #2 state = REVERSE ? S1 : S2;
  end
endmodule

module test_fsm_coverage_distinguishes_directed_transitions;
  directed_fsm forward_path();
  directed_fsm #(.REVERSE(1)) reverse_path();
  initial begin
    $display("states=%0d,%0d", forward_path.state, reverse_path.state);
    #1;
    repeat (4) begin
      #2;
      $display("states=%0d,%0d", forward_path.state, reverse_path.state);
    end
  end
endmodule
