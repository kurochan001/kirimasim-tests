/*
:name: test_vpi_coverage_max_entities
:description: vpiCoveredMax counts the coverable entities of a signal, a statement block, an FSM, an FSM state and an assertion handle, vpi_get_value gives the value of each FSM state, and the covered and covered-count values stay within the maxima (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.4 40.4.1 40.4.6 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_max_entities.c
:expected_stdout: @test_vpi_coverage_max_entities.expected
*/
// IEEE 1800-2023 §40.5.2: vpiCoveredMax is the number of coverable entities
// of a handle. For a signal handle the entities are the bits of the signal, so
// the 8-bit sig has 8, and for a statement handle they are statements, so the
// three assignments of the task steps have 3 (§37.12: vpiStmt of a task with
// more than one statement is an unnamed begin that contains them). For an FSM
// handle they are the FSM states, which the pragmas of §40.4 fix at three, and
// for an FSM state and an assertion handle the number is always 1.
// vpi_get_value at an FSM state handle gives the value of that state. vpi_get
// at an instance handle with a coverage type counts its covered items
// (§40.5.2), and that count cannot be smaller than the covered bits of a
// signal of the instance. vpiCovered is the number of covered entities and
// vpiCoveredCount the sum of the times they were covered, so neither can
// exceed the maximum and the second cannot be smaller than the first. Each of
// the eight bits of sig toggles once and the task runs once, so the covered
// counts of the signal and of the statement block are their maxima; the FSM
// goes through all three of its states before the counts are read at 26, so
// its covered value is its maximum too. A tool that collects no coverage for a
// type is left out of the checks of its collected values, but the maxima are
// always checked.

`timescale 1ns/1ns

module test_vpi_coverage_max_entities;
  logic clk = 0;
  logic [7:0] sig = 8'h00;
  bit on = 1'b1;
  int step_a, step_b, step_c;

  /* tool state_vector st enum seq_states */
  logic [1:0] st = 0;
  parameter [1:0] /* tool enum seq_states */ S_IDLE = 0, S_RUN = 1, S_DONE = 2;

  int toggle_check, statement_check, assertion_check, fsm_check;

  always #5 clk = ~clk;

  always @(posedge clk)
    case (st)
      S_IDLE: st <= S_RUN;
      S_RUN: st <= S_DONE;
      default: st <= S_IDLE;
    endcase

  a_pass: assert property (@(posedge clk) on);

  task automatic steps();
    step_a = 1;
    step_b = step_a + 1;
    step_c = step_b + 1;
  endtask

  initial begin
    sig = 8'hff;
    steps();
    toggle_check =
        $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_HIER,
                          test_vpi_coverage_max_entities);
    statement_check =
        $coverage_control(`SV_COV_CHECK, `SV_COV_STATEMENT, `SV_COV_HIER,
                          test_vpi_coverage_max_entities);
    assertion_check =
        $coverage_control(`SV_COV_CHECK, `SV_COV_ASSERTION, `SV_COV_HIER,
                          test_vpi_coverage_max_entities);
    fsm_check =
        $coverage_control(`SV_COV_CHECK, `SV_COV_FSM_STATE, `SV_COV_HIER,
                          test_vpi_coverage_max_entities);
    #26 $vt_cov(toggle_check, statement_check, assertion_check, fsm_check);
    $finish;
  end
endmodule
