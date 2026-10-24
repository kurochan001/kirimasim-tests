/*
:name: test_vpi_loop_branch_children
:description: while and do-while give their condition with vpiCondition and their body with vpiStmt, repeat, forever and foreach their body, if and if-else their condition, their statement, the else statement of if-else and the unique or priority qualifier, and a return statement its expression with vpiCondition (IEEE 1800-2023 Section 37.66)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.66 37.70 37.71 37.75 37.78 37.12 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_loop_branch_children.c
:expected_stdout: @test_vpi_loop_branch_children.expected
*/
// IEEE 1800-2023 §37.66: while leads to its condition (vpiCondition) and its
// body (vpiStmt), and so does repeat, whose condition is the count. §37.70:
// forever leads to its body. §37.71: if and if-else lead to their condition
// and their statement, if-else also to its else statement (vpiElseStmt), and
// both have vpiQualifier: vpiNoQualifier (0) without a keyword, and
// vpiUniqueQualifier (1) or vpiPriorityQualifier (2) for unique and priority
// (12.4.2; values from sv_vpi_user.h, Annex M). §37.75: do-while leads to its
// condition and body, foreach to its body. §37.78: a return statement leads to
// its expression with vpiCondition, which is NULL for a return without one.
//
// The task bodies is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). The function plus_one has one statement, the return,
// which is its vpiStmt. Every condition is a different variable and every
// body a different assignment v = N, so each line names the objects it found;
// the application prints an assignment as v = N, an expression by its name,
// value or, for an addition, its two operands, and NULL as none. The lines of
// the task are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the statement types, and a run
// with Verilator 5.052 gives no statements of the task or the function.

module test_vpi_loop_branch_children;
  bit a, b, c, d, e, g;
  int v;
  int arr [3];

  function int plus_one(int x);
    return x + 1;
  endfunction

  task bodies;
    while (a) v = 1;
    repeat (3) v = 2;
    forever v = 3;
    if (b) v = 4;
    if (c) v = 5; else v = 6;
    unique if (d) v = 7; else v = 8;
    priority if (e) v = 9;
    do v = 10; while (g);
    foreach (arr[i]) v = 11;
    return;
  endtask
endmodule
