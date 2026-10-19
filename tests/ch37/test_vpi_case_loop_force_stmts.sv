/*
:name: test_vpi_case_loop_force_stmts
:description: the statements of a named block give a case with its type, qualifier, condition and items, a foreach with its array and loop variables, a skipped one as a null operation, a do-while with its condition, and force, release, assign and deassign with their left- and right-hand sides (IEEE 1800-2023 Sections 37.72, 37.75, 37.79)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.72 37.75 37.79 37.12 12.5 12.7.3 12.7.5 10.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_case_loop_force_stmts.c
:expected_stdout: @test_vpi_case_loop_force_stmts.expected
*/
// IEEE 1800-2023 §37.12: a named block iterates its statements with vpiStmt.
// §37.72: a case (§12.5) has vpiCaseType (vpiCaseExact, vpiCaseX or
// vpiCaseZ), vpiQualifier, vpiCondition and its case items; an item groups
// all expressions that lead to its statement (detail 1), and vpiExpr gives
// none for the default item (detail 2). §37.75: a foreach (§12.7.3) has the
// indexed array as vpiVariables and its loop variables as vpiLoopVars, a
// skipped one being an operation with vpiOpType vpiNullOp (detail 2); a
// do-while (§12.7.5) has vpiCondition. §37.79: force and assign have vpiLhs
// and vpiRhs, release and deassign vpiLhs (§10.6). The application prints
// one line per statement, in order.

`timescale 1ns/1ns

module test_vpi_case_loop_force_stmts;
  logic [1:0] sel = 1;
  int m [2][3];
  logic f = 0, g = 0;
  int i = 0;

  initial begin : stmts
    unique case (sel)
      2'd0: g = 0;
      2'd1, 2'd2: g = 1;
      default: g = f;
    endcase
    casez (sel)
      2'b1?: g = 1;
    endcase
    foreach (m[, j]) i = j;
    do i = i - 1; while (i > 0);
    force f = 1;
    release f;
    assign g = f;
    deassign g;
  end

  initial #1 $vt_stmts;
endmodule
