/*
:name: test_vpi_for_expect_children
:description: A for statement gives its initializations and steps with vpiForInitStmt and vpiForIncStmt, both as one statement and as an iteration, its condition, its body and vpiLocalVarDecls; an expect statement gives its property spec, its pass statement and its else statement (IEEE 1800-2023 Section 37.74)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.74 37.73 37.52 37.64 12.7.1 16.17 37.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_for_expect_children.c
:expected_stdout: @test_vpi_for_expect_children.expected
*/
// IEEE 1800-2023 §37.74: a for statement leads to its initialization
// statements and its step statements, with vpi_handle and with vpi_iterate,
// through vpiForInitStmt and vpiForIncStmt, to its condition (vpiCondition)
// and to its body (vpiStmt); vpiLocalVarDecls says whether it declares its
// loop variables (12.7.1). A step written as an assignment operator is an
// assignment whose vpiOpType is the operator, vpiAddOp for += and vpiSubOp for
// -= (37.64 detail 1). §37.73: an expect statement (16.17) leads to its
// property spec, to the statement of its action block (vpiStmt) and to the
// statement after else (vpiElseStmt). §37.52: the property spec leads to its
// clocking event (vpiClockingEvent) and its disable condition
// (vpiDisableCondition); a disable iff after the clocking event makes that
// event the one of the property spec.
//
// The task stmts is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). The first loop has two initializations and two steps, so
// only the iterations are used; the second has one of each, so both the
// handle and the iteration are; the third declares its variable, so only its
// condition, step and body are printed. Each loop and each expect has its
// own body v = N, by which the lines are sorted; the initializations and
// steps of an iteration are sorted too. An operation is printed as its two
// operands around its operator, a NULL handle as none.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the statement types, and the
// expect statement stops Verilator 5.052, which does not support it.

module test_vpi_for_expect_children;
  bit clk, a1, a2, r1, r2;
  int v, i, j, k;

  task stmts;
    for (i = 0, j = 9; i < j; i += 1, j -= 1) v = 100;
    for (k = 2; k < 5; k += 2) v = 200;
    for (int m = 0; m < 3; m += 1) v = 300;
    expect (@(posedge clk) disable iff (r1) a1) v = 1; else v = 2;
    expect (@(negedge clk) disable iff (r2) a2) v = 3;
  endtask
endmodule
