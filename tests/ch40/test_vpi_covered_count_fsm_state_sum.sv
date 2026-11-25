/*
:name: test_vpi_covered_count_fsm_state_sum
:description: FSM coverage hit counts include repeated visits and the FSM total equals the sum for its states
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.4.1 40.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: --fsm-coverage
:vpi_c: @test_vpi_covered_count_fsm_state_sum.c
:expected_stdout: @test_vpi_covered_count_fsm_state_sum.expected
*/
// The VPI application samples at times 3 and 11. Between those samples
// states 1 and 2 each receive two visits. State 3 is declared and never used.
// Enable FSM collection at invocation so the test exercises hit counts.
`timescale 1ns/1ns
module fsm_count_unit;
  /* tool state_vector state enum counted_modes */
  logic [1:0] state = 0;
  parameter [1:0] /* tool enum counted_modes */ S0 = 0, S1 = 1, S2 = 2, S3 = 3;
  int visits[4] = '{default:0};

  task automatic enter_state(input logic [1:0] next_state);
    state = next_state;
    visits[next_state]++;
  endtask

  initial begin
    #2 enter_state(S1);
    #2 enter_state(S2);
    #2 enter_state(S1);
    #2 enter_state(S2);
    #2 enter_state(S1);
  end
endmodule

module test_vpi_covered_count_fsm_state_sum;
  fsm_count_unit counted();

  initial #11 $display("hdl visits=%0d,%0d,%0d,%0d",
                       counted.visits[0], counted.visits[1], counted.visits[2], counted.visits[3]);
endmodule
