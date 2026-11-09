/*
:name: test_vpi_coverage_partial_entities
:description: vpiCovered counts the covered entities of a signal, a statement block and an FSM handle, also when only some are covered, and vpi_get with vpiToggleCoverage on an instance counts its covered bits (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.2.2 40.4 37.12 40.3.2.1 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_partial_entities.c
:expected_stdout: @test_vpi_coverage_partial_entities.expected
*/
// IEEE 1800-2023 §40.5.2: for a handle with several coverable entities,
// vpiCovered gives how many of them are covered: the bits of a signal, the
// statements of a statement handle, the states of an FSM; for one FSM state it
// gives whether it is covered. vpiCoveredCount gives how many times an entity
// was covered, summed over the entities of the handle, and vpiCoveredMax the
// number of entities. vpi_get(<coverage type>, instance) gives the number of
// covered items of that type in the instance, the number that $coverage_get
// (40.3.2.3) gives for it.
//
// Bits 0 to 2 of u.sig go from 0 to 1 and back, the other five stay 0, so 3
// of the 8 bits are covered (40.2.2), and u has no other signal. The task
// steps, whose three statements form an unnamed begin block (37.12), runs
// twice: its 3 statements are covered. How often each was covered
// (vpiCoveredCount) is not checked: 40.2.2 makes execution counts optional.
// The task idle never runs, so none of
// its 2 statements is covered. The FSM named by the pragmas (40.4) has the
// states 0, 1 and 2; by 26 st has been assigned 1 and 0 but never 2, so 2 of
// its 3 states are covered. A tool that gave the maximum for vpiCovered
// prints 0 on some line. The
// covered values exist only where the tool collects that coverage, so each is
// checked only where the check of its scope (40.3.2.1) gives SV_COV_OK; the
// maxima are always checked.

`timescale 1ns/1ns

module test_vpi_coverage_partial_entities_unit;
  logic [7:0] sig = 8'h00;
endmodule

module test_vpi_coverage_partial_entities;
  logic clk = 0;
  int step_a, step_b, step_c, idle_a, idle_b;
  int toggle_check, statement_check, fsm_check, toggle_u;

  /* tool state_vector st enum pe_states */
  logic [1:0] st = 2'd0;
  parameter [1:0] /* tool enum pe_states */ P0 = 0, P1 = 1, P2 = 2;

  test_vpi_coverage_partial_entities_unit u();

  always #5 clk = ~clk;
  always @(posedge clk) st <= st == P0 ? P1 : P0;

  task automatic steps();
    step_a = 1;
    step_b = step_a + 1;
    step_c = step_b + 1;
  endtask

  task automatic idle();
    idle_a = 1;
    idle_b = 2;
  endtask

  initial begin
    toggle_check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_MODULE, u);
    statement_check = $coverage_control(`SV_COV_CHECK, `SV_COV_STATEMENT, `SV_COV_MODULE,
                                        test_vpi_coverage_partial_entities);
    fsm_check = $coverage_control(`SV_COV_CHECK, `SV_COV_FSM_STATE, `SV_COV_MODULE,
                                  test_vpi_coverage_partial_entities);
    u.sig = 8'h07;
    #1 u.sig = 8'h00;
    steps();
    steps();
    #25 toggle_u = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, u);
    $vt_cov(toggle_check, statement_check, fsm_check, toggle_u);
    $finish;
  end
endmodule
