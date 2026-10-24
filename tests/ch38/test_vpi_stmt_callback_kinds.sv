/*
:name: test_vpi_stmt_callback_kinds
:description: cbStmt callbacks come once before the statements of unnamed and named begin and fork blocks, before the condition of an if-else, before case, assign, deassign, force, release, event trigger, task call, wait and disable statements, on every iteration of while, repeat and forever loops, each with a new s_cb_data that holds cbStmt, the routine, the statement, the time of the requested type or NULL, a NULL value, index 0 and the user data (IEEE 1800-2023 Sections 38.36.1.1 and 38.36.1.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.2 38.36.1.1 38.36.1 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_stmt_callback_kinds.c
:expected_stdout: @test_vpi_stmt_callback_kinds.expected
*/
// IEEE 1800-2023 §38.36.1: a cbStmt callback occurs before a behavioral
// statement executes. §38.36.1.1: it is registered with the routine, the
// statement in obj, a time whose type only is used (vpiSimTime,
// vpiScaledRealTime or vpiSuppressTime) and user_data; value and index are
// not used. Just before the statement executes, the routine gets a new
// s_cb_data with reason cbStmt, the same cb_rtn, the statement in obj, the
// current time in the requested type or NULL for vpiSuppressTime, value
// NULL, index 0 and the registered user_data. §38.36.1.2 (Table 38-6): for a
// begin, named begin, fork or named fork block, one callback comes before
// any statement in it, with the block in obj; for if-else, before the
// condition is evaluated; for while, before the condition on every
// iteration; for repeat and forever, when first encountered and on every
// later iteration; for wait, case, assign, deassign, disable, force,
// release and event trigger statements, before the statement; for a task
// call, before the task runs.
//
// At the start of the simulation (38.36.3) the application places a callback
// on the initial block, on each statement in it and on the forever loop in
// fl, all with vpiSimTime except the assignment step = 1 (vpiScaledRealTime)
// and the case statement (vpiSuppressTime), with a value of an undefined
// format and an index of 77. Each callback prints the time, step and the
// variable that the statement or its condition changes; bump() counts the
// conditions evaluated. A delay of 1 follows the assign and the force
// statements, so that the next callbacks see their effect whenever it
// happens in the time step. The clause does not say whether the evaluation
// that ends a while or repeat loop has a callback, so for these loops the
// application prints at the end (38.36.3) the first callbacks and whether
// their number is one of the two possible ones.
// Icarus Verilog 13.0 has no statement types in its vpi_user.h, and the
// VPI of Verilator 5.052 gives no processes.

`timescale 1ns/1ns

module test_vpi_stmt_callback_kinds;
  int step = 0, calls = 0, q = 0, r = 0;
  logic [3:0] wd = 4'd1;
  wire [3:0] w;
  event e;

  assign w = wd;

  function int bump();
    calls++;
    return calls;
  endfunction

  task set_r(input int v);
    r = v;
  endtask

  initial begin
    #3;
    step = 1;
    begin
      step = 2;
    end
    begin : nb
      step = 3;
    end
    fork
      step = 4;
    join
    fork : nf
      step = 5;
    join
    if (bump() == 1) step = 6;
    else step = 60;
    case (step)
      6: step = 7;
      default: step = 70;
    endcase
    assign q = 8;
    #1;
    deassign q;
    force w = 4'd9;
    #1;
    release w;
    -> e;
    set_r(11);
    wait (r == 11) step = 12;
    disable nb;
    while (bump() < 4) step = step + 1;
    repeat (3) step = step + 1;
    begin : fl
      forever begin
        step = step + 1;
        if (step == 20) disable fl;
      end
    end
    $display("design: step=%0d calls=%0d q=%0d r=%0d w=%0d", step, calls, q, r, w);
  end
endmodule
