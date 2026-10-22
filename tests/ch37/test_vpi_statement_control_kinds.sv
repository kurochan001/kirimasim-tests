/*
:name: test_vpi_statement_control_kinds
:description: VPI gives the statement objects of immediate assertions, event triggers, while, repeat, wait, forever, if, expect, for, disable and return (IEEE 1800-2023 Sections 37.55, 37.62, 37.66, 37.67, 37.70, 37.71, 37.73, 37.74, 37.77 and 37.78)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.55 37.62 37.66 37.67 37.70 37.71 37.73 37.74 37.77 37.78
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_statement_control_kinds.c
:expected_stdout: @test_vpi_statement_control_kinds.expected
*/
// IEEE 1800-2023 §37.55: immediate assert, assume and cover are statements of
// type vpiImmediateAssert, vpiImmediateAssume and vpiImmediateCover.
// §37.62: an event trigger is vpiEventStmt. §37.66: while and repeat are
// vpiWhile and vpiRepeat. §37.67: wait is vpiWait. §37.70: forever is
// vpiForever. §37.71: if and if-else are vpiIf and vpiIfElse. §37.73: expect
// is vpiExpectStmt. §37.74: for is vpiFor. §37.77: disable is vpiDisable.
// §37.78: return is vpiReturnStmt. The task stmts is never called, so the
// statements only exist as VPI objects and none of them runs. The application
// prints their types sorted, as no sentence fixes the order of vpi_iterate.

module test_vpi_statement_control_kinds;
  logic en = 0;
  event e;

  task stmts;
    a1: assert (en);
    a2: assume (en);
    a3: cover (en);
    -> e;
    while (en) ;
    repeat (1) ;
    wait (en);
    forever ;
    if (en) ; else ;
    expect (en);
    for (int i = 0; i < 1; i++) ;
    disable stmts;
    return;
  endtask

  initial #1 $vt_list;
endmodule
