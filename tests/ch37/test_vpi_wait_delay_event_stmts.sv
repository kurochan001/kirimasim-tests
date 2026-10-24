/*
:name: test_vpi_wait_delay_event_stmts
:description: wait gives its condition and statement, wait_order its events with vpiCondition, its statement and its else statement, a delay control statement its delay with vpiDelay and its statement, an intra-assignment delay control no statement, and an event trigger its named event and vpiBlocking true for -> and false for ->> (IEEE 1800-2023 Section 37.67)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.67 37.68 37.62 37.64 9.4.1 9.4.5 15.5.1 15.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_wait_delay_event_stmts.c
:expected_stdout: @test_vpi_wait_delay_event_stmts.expected
*/
// IEEE 1800-2023 §37.67: every member of the waits group leads to its
// statement (vpiStmt); wait leads to its condition with vpiCondition, and an
// ordered wait (wait_order, 15.5.4) iterates its events with vpiCondition and
// leads to the statement after else with vpiElseStmt. §37.68: a delay control
// leads to its delay expression with vpiDelay and to the statement it
// controls, which is NULL for a delay control inside an assignment (detail 1;
// the assignment leads to it with vpiDelayControl, §37.64; 9.4.5). §37.62: an
// event trigger leads to its named event, and vpiBlocking is TRUE for -> and
// FALSE for the nonblocking trigger ->> (15.5.1).
//
// The task stmts is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Each object is told apart by its names and values: the
// application prints an assignment as v = N, an expression by its name or
// value, NULL as none, and the events of the ordered wait sorted by name, as
// no sentence fixes the order of that iteration. The lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the statement types, and the
// wait_order statement stops Verilator 5.052, which does not support it.

module test_vpi_wait_delay_event_stmts;
  bit ready;
  int v, dly;
  event e1, e2, e3, go, done;

  task stmts;
    wait (ready) v = 1;
    wait_order (e1, e2, e3) v = 2; else v = 3;
    #dly v = 4;
    v = #7 5;
    -> go;
    ->> done;
  endtask
endmodule
