/*
:name: test_vpi_fsm_from_pragmas
:description: An FSM described with the pragmas of 40.4 is found through VPI in its instance, with its state signal, its states and their values, and each state counts as one coverable item (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.4 40.4.1 40.4.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_fsm_from_pragmas.c
:expected_stdout: @test_vpi_fsm_from_pragmas.expected
*/
// IEEE 1800-2023 §40.4: the FSM pragmas override a tool's own extraction of
// FSMs. Here they name st as the state vector of the enumeration seq_states
// (40.4.1) and the three parameters as its states (40.4.6). §40.5.2:
// vpi_iterate(vpiFsm, instance) gives the FSMs of the instance,
// vpi_handle(vpiFsmStateExpression) the signal holding the state,
// vpi_iterate(vpiFsmStates) the states, whose value vpi_get_value gives, and
// vpiCoveredMax is the number of coverable items: the states of an FSM, and
// always 1 for a state. The application prints the state values sorted.

`timescale 1ns/1ns

module test_vpi_fsm_from_pragmas;
  logic clk = 0;
  /* tool state_vector st enum seq_states */
  logic [1:0] st = 0;
  parameter [1:0] /* tool enum seq_states */ S_IDLE = 0, S_RUN = 1, S_DONE = 2;

  always #5 clk = ~clk;

  always @(posedge clk)
    case (st)
      S_IDLE: st <= S_RUN;
      S_RUN: st <= S_DONE;
      default: st <= S_IDLE;
    endcase

  initial #20 $vt_fsm;
endmodule
