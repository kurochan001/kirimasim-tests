/*
:name: test_vpi_immediate_assertion_parts
:description: Each immediate assert, assume and cover gives its condition with vpiExpr, its pass statement with vpiStmt and, for assert and assume, its else statement with vpiElseStmt, and says with vpiIsDeferred and vpiIsFinal whether it is a simple, an observed deferred (#0) or a final deferred assertion (IEEE 1800-2023 Section 37.55)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.55 16.3 16.4 37.12 37.42 37.64
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_immediate_assertion_parts.c
:expected_stdout: @test_vpi_immediate_assertion_parts.expected
*/
// IEEE 1800-2023 §37.55: an immediate assert, assume or cover leads to its
// condition (vpiExpr) and to the statement of its action block (vpiStmt);
// assert and assume also lead to the statement after else (vpiElseStmt).
// vpiIsDeferred tells a deferred assertion from a simple one, and vpiIsFinal
// a final deferred one. §16.4: #0 makes an observed deferred assertion and
// final a final deferred one; both kinds are deferred assertions, and the
// action block of a deferred assertion is a single subroutine call. An action
// block without a statement before else (16.3) has no pass statement, and one
// without else has no else statement, so those relations give NULL.
//
// The task checks is never called, so its statements only exist as VPI
// objects; as it has several statements, its vpiStmt is an unnamed begin
// holding them (37.12 detail 5). From a start-of-simulation callback the
// application prints, for each assertion, the name of its condition, its kind,
// whether vpiIsDeferred and vpiIsFinal are nonzero, and its pass and else
// statements: an assignment as target = value (37.64), a task call by the
// name of the task (37.42), NULL as none. Each condition is a different
// variable, so the lines are sorted by its name.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its sv_vpi_user.h lacks the constants of Annex M used here,
// and Verilator 5.052 gives no statements of the task (statements: 0).

module test_vpi_immediate_assertion_parts;
  bit c00, c01, c02, c03, c04, c05, c06, c07, c08, c09, c10;
  int v;

  task pass_t;
  endtask

  task fail_t;
  endtask

  task checks;
    assert (c00) v = 1; else v = 2;
    assert #0 (c01) pass_t(); else fail_t();
    assert final (c02) pass_t(); else fail_t();
    assert (c03) v = 3;
    assert (c04) else v = 4;
    assume (c05) v = 5; else v = 6;
    assume #0 (c06) pass_t(); else fail_t();
    assume final (c07) pass_t();
    cover (c08) v = 7;
    cover #0 (c09) pass_t();
    cover final (c10) fail_t();
  endtask
endmodule
