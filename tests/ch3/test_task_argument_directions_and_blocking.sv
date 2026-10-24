/*
:name: test_task_argument_directions_and_blocking
:description: A task called as a statement from two places takes input, output, inout and ref arguments and returns at a later time; input is copied in, output and inout are copied out when it returns, and ref acts on the actual during the call (IEEE 1800-2023 Section 3.8)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.8 13.3 13.5 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_argument_directions_and_blocking.expected
*/
// IEEE 1800-2023 §3.8: a subroutine is code that can be called from one or
// more places; a task is called as a statement, can have input, output,
// inout and ref arguments, returns no value and can block, so it can return
// at a later time than it was called. §13.5: input values are passed in when
// the call starts and output and inout values are passed back when it
// returns; §13.5.2: a ref argument is a reference to the actual itself.
// The automatic task work takes a = 3, o, io = 10 and r = 100 at time 0,
// writes o = 6, io = 13 and r = 103, waits 5 time units, and then adds a to
// o and 1 to io and r. At time 2, while it waits, another process prints the
// actuals and then changes them: va to 50, vio to 77 and vr to 200.
// - At time 2 vo and vio still have their old values 0 and 10, and vr is
//   already 103.
// - After the return at time 5, vo is 9 (a stayed 3 in the task), vio is 14
//   (the copy out overwrites 77) and vr is 201 (r is the changed vr).
// A second call from another initial procedure at time 10 with a = 1 starts
// from the values left by the first call and returns at time 15.
// Icarus Verilog 13.0 does not support ref arguments ("sorry: Reference
// ports not supported yet").

`timescale 1ns/1ns

module test_task_argument_directions_and_blocking;
  int va = 3, vo = 0, vio = 10, vr = 100;
  int calls = 0;

  task automatic work(input int a, output int o, inout int io, ref int r);
    calls++;
    o = a * 2;
    io = io + a;
    r = r + a;
    #5;
    o = o + a;
    io = io + 1;
    r = r + 1;
  endtask

  initial begin
    work(va, vo, vio, vr);
    $display("t=%0t after first call: va=%0d vo=%0d vio=%0d vr=%0d calls=%0d", $time, va, vo,
             vio, vr, calls);
  end

  initial begin
    #2;
    $display("t=%0t during first call: va=%0d vo=%0d vio=%0d vr=%0d calls=%0d", $time, va, vo,
             vio, vr, calls);
    va = 50;
    vio = 77;
    vr = 200;
  end

  initial begin
    #10;
    work(1, vo, vio, vr);
    $display("t=%0t after second call: vo=%0d vio=%0d vr=%0d calls=%0d", $time, vo, vio, vr,
             calls);
  end
endmodule
