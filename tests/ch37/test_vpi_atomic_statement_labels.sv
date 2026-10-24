/*
:name: test_vpi_atomic_statement_labels
:description: vpiName of an atomic statement is its statement label for if-else, while, repeat, wait, ordered wait, wait fork, for, delay control, event trigger, disable, disable fork, forever, do-while, expect, foreach, return, break, continue and immediate assert, assume and cover, and NULL for a statement without a label (IEEE 1800-2023 Section 37.60)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.60 9.3.5 37.12 37.66 37.67 37.68 37.77
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_atomic_statement_labels.c
:expected_stdout: @test_vpi_atomic_statement_labels.expected
*/
// IEEE 1800-2023 §37.60: all the statement kinds used below are in the atomic
// statement group (waits and disables are groups within it, §37.67, §37.77),
// whose property vpiName gives the statement label if one was given and NULL
// otherwise (detail 1). §9.3.5: any procedural statement can have a label; for
// most kinds the label also makes a named block around the statement, and on
// a foreach it names the implicit block of the loop. Where an implementation
// shows such a block as a named begin, the application looks through it at
// the statement inside, which still carries its label.
//
// The task labeled is never called, so its statements only exist as VPI
// objects; it has several statements, so its vpiStmt is an unnamed begin
// (37.12 detail 5). Each labeled statement has a label of its own, and the
// statements under the labeled while and repeat have labels too. The
// statement controlled by the delay control and by the wait, an unlabeled
// if-else and a null statement (which cannot have a label) have none. From a
// start-of-simulation callback the application prints the kind and vpiName of
// each statement of the begin, and of the statement under the while, repeat,
// wait and delay control; the lines are sorted.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStmt and the statement types, and the
// expect statement stops Verilator 5.052, which does not support it.

module test_vpi_atomic_statement_labels;
  bit c, clk;
  int v, n;
  int arr [2];
  event e, f;

  task worker;
  endtask

  task labeled;
    l_if: if (c) v = 1; else v = 2;
    l_while: while (c) l_break: break;
    l_repeat: repeat (2) l_continue: continue;
    l_wait: wait (c) v = 3;
    l_order: wait_order (e, f) v = 14; else v = 15;
    l_wfork: wait fork;
    l_for: for (n = 0; n < 2; n += 1) v = n;
    l_delay: #1 v = 4;
    l_event: -> e;
    l_disable: disable worker;
    l_dfork: disable fork;
    l_forever: forever #1 v = 5;
    l_do: do v = 6; while (c);
    l_expect: expect (@(posedge clk) c) v = 7; else v = 8;
    l_foreach: foreach (arr[i]) v = arr[i];
    l_assert: assert (c) v = 9;
    l_assume: assume (c) v = 10;
    l_cover: cover (c) v = 11;
    l_return: return;
    if (c) v = 12; else v = 13;
    ;
  endtask
endmodule
