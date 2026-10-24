/*
:name: test_structured_procedure_kinds_each_run
:description: a procedure of each kind, initial, always, always_comb, always_latch, always_ff, final, task and function, runs and gives its result (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2 9.2.2.2 9.2.2.3 9.2.2.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_structured_procedure_kinds_each_run.expected
*/
// IEEE 1800-2023 §9.2: the structured procedures are initial procedures,
// always procedures written with always, always_comb, always_latch or
// always_ff, final procedures, tasks and functions.
//
// The module has one procedure of each kind, and each writes its own
// variable: always toggles clk every 5 time units, always_comb computes
// a & b, always_latch passes d while en is 1, always_ff samples d at the
// rising edge of clk, the task and the function compute a value when the
// initial procedure calls them, and the final procedure prints at the end.
// The initial procedure changes the inputs and prints the outputs at fixed
// times between the clock edges (5, 15), so each value shows that its
// procedure ran: comb_y follows b at once, latch_q keeps 1 after en falls,
// and ff_q changes only at the next rising edge.

`timescale 1ns/1ns

module test_structured_procedure_kinds_each_run;
  logic clk = 1'b0;
  logic a = 1'b0, b = 1'b0, en = 1'b0, d = 1'b0;
  logic comb_y, latch_q, ff_q;
  int task_v = 0;

  always #5 clk = ~clk;

  always_comb comb_y = a & b;

  always_latch
    if (en) latch_q = d;

  always_ff @(posedge clk) ff_q <= d;

  task set_task_v(input int v);
    task_v = v;
  endtask

  function int add_func(input int x, input int y);
    return x + y;
  endfunction

  initial begin
    a = 1'b1;
    b = 1'b1;
    d = 1'b1;
    en = 1'b1;
    #1 $display("t=1: comb_y=%b latch_q=%b", comb_y, latch_q);
    #5 $display("t=6: ff_q=%b", ff_q);
    en = 1'b0;
    d = 1'b0;
    b = 1'b0;
    #1 $display("t=7: comb_y=%b latch_q=%b ff_q=%b", comb_y, latch_q, ff_q);
    #9 $display("t=16: ff_q=%b clk=%b", ff_q, clk);
    set_task_v(add_func(20, 3));
    $display("task_v=%0d", task_v);
    $finish;
  end

  final $display("final at %0t", $time);
endmodule
