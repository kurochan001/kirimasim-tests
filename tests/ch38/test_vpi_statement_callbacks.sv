/*
:name: test_vpi_statement_callbacks
:description: A cbStmt callback runs before its statement executes, on every iteration of a while loop and once before the statements of a block, and one placed on a module instance covers all its statements until it is removed (IEEE 1800-2023 Section 38.36.1.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.1 38.36.1.2 38.36.1.3 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_statement_callbacks.c
:expected_stdout: @test_vpi_statement_callbacks.expected
*/
// IEEE 1800-2023 §38.36.1.1: a cbStmt callback is called just before its
// statement executes, with the statement in obj. §38.36.1.2 (Table 38-6): for a
// while loop it comes before the condition is evaluated on every iteration, so
// three or four times for three iterations, as the clause does not say whether
// the last evaluation, which ends the loop, counts; for a named begin-end block
// it comes once, before its statements. §38.36.1.3: a cbStmt callback placed on
// a module instance covers every statement of it, and removing its one handle
// removes them all. The callbacks are placed at the end of compilation
// (38.36.3). w's statements before time 1 are counted; the callback is removed
// at time 1, before w's second assignment.

`timescale 1ns/1ns

module test_vpi_statement_callbacks_worker;
  int k = 0;

  initial begin
    k = 1;
    #2 k = 2;
  end
endmodule

module test_vpi_statement_callbacks;
  int i = 0;

  test_vpi_statement_callbacks_worker w();

  initial begin : body
    while (i < 3)
      i = i + 1;
    #1 $vt_remove;
    #2 $vt_report;
  end
endmodule
