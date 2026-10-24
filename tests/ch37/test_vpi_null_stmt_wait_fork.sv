/*
:name: test_vpi_null_stmt_wait_fork
:description: A lone semicolon in a block, in a branch of an if-else, in a case item and under a delay control and a wait is a vpiNullStmt object with no label, and a wait fork is a vpiWaitFork statement with its label or NULL and no statement (IEEE 1800-2023 Section 37.60)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.60 37.67 37.71 37.72 37.68 9.3.5 9.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_null_stmt_wait_fork.c
:expected_stdout: @test_vpi_null_stmt_wait_fork.expected
*/
// IEEE 1800-2023 §37.60: the null statement is an atomic statement of its
// own kind, vpiNullStmt, and like every atomic statement has the property
// vpiName, the statement label if one was given and NULL otherwise
// (detail 1). A.6.4 gives a lone semicolon no label, so a null statement
// always has NULL. §37.67: wait fork is in the waits group, whose members
// lead to their statement with vpiStmt; A.6.5 gives wait fork no statement,
// only its terminating semicolon, while wait (expression) is followed by a
// statement, which can be a null statement. §37.71, §37.72 and §37.68: an
// if-else, a case item and a delay control lead to their statements with
// vpiStmt and vpiElseStmt. §9.3.5: a label before a wait fork also makes a
// named block around it; where an implementation shows such a block, the
// application looks through it at the statement inside, which still carries
// its label.
//
// The task stmts is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). From a start-of-simulation callback the application
// prints, for each statement of that begin, its kind and label, and the kind
// and label of the statements it leads to (each case item with its
// expression, default when it has none); the lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the statement types, and a
// run with Verilator 5.052 gives no statement for the task.

module test_vpi_null_stmt_wait_fork;
  bit c;
  int v, s;

  task stmts;
    if (c) ; else v = 1;
    case (s)
      0: ;
      default: v = 2;
    endcase
    #1 ;
    wait (c) ;
    ;
    l_wfork: wait fork;
    wait fork;
  endtask
endmodule
