/*
:name: test_function_returns_at_once_task_waits
:description: a function returns to its caller in the same time step, even when it starts a fork-join_none with a delay or makes a nonblocking assignment, a task may wait, and only a nonvoid function gives a value usable as an operand (IEEE 1800-2023 Section 13.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.2 13.4.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_returns_at_once_task_waits.expected
*/
// IEEE 1800-2023 §13.2: the body of a function executes in one simulation time
// unit, while a task may contain time-controlling statements; a nonvoid
// function returns a single value, which can be an operand of an expression,
// and a task or void function returns no value. §13.4.4: a function may start
// a fork-join_none and make nonblocking assignments; it still returns at once,
// and what it scheduled happens later.
// start, called at t=1, starts a process that waits 3 units and makes a
// nonblocking assignment to v; it returns 8 at t=1, when v is still 0. The
// task wait_then waits 2 units, so the caller goes on at t=3, when v is 4 and
// the process of start has not run yet; it runs at t=4. twice is used as an
// operand of an arithmetic expression, of a condition and of an index. The
// void function note and the task wait_then give their results only through
// output arguments, and their return statements have no expression and end
// them early.
// Icarus Verilog 13.0 does not support output arguments of functions.

`timescale 1ns/1ns
module test_function_returns_at_once_task_waits;
  int v = 0, spawned_at = -1;
  int arr [4] = '{10, 11, 12, 13};

  function automatic int start(int d);
    fork
      #3 spawned_at = $time;
    join_none
    v <= d;
    return d * 2;
  endfunction

  function int twice(int a);
    return 2 * a;
  endfunction

  function automatic void note(int a, output int o);
    o = a + 100;
    if (a > 0) return;
    o = -1;
  endfunction

  task automatic wait_then(int d, output int r);
    #d;
    r = d * 3;
    if (d > 0) return;
    r = -1;
  endtask

  initial begin
    int r, n, o1, o2;
    #1;
    r = start(4);
    $display("t=%0t start returned %0d, v=%0d", $time, r, v);
    wait_then(2, n);
    $display("t=%0t wait_then gave %0d, v=%0d spawned_at=%0d", $time, n, v, spawned_at);
    n = twice(3) + twice(twice(1)) * 10;
    $display("twice: sum=%0d cond=%0d elem=%0d", n, twice(2) == 4 ? 1 : 0, arr[twice(1)]);
    note(5, o1);
    note(0, o2);
    $display("note: %0d %0d", o1, o2);
    #2 $display("t=%0t the process of start ran at t=%0d", $time, spawned_at);
  end
endmodule
