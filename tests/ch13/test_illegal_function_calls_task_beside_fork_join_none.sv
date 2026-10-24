/*
:name: test_illegal_function_calls_task_beside_fork_join_none
:description: a function cannot enable a task directly, though a fork-join_none in it may (IEEE 1800-2023 Section 13.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.2 13.4.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f enables the task t directly
:expected_stderr_regex: test_illegal_function_calls_task_beside_fork_join_none\.sv:41:
*/
// IEEE 1800-2023 §13.2: a function cannot enable a task, while a task can
// enable other tasks and functions; 13.4.4 makes an exception for a
// fork-join_none in a function, which may contain any statement legal in a
// task. task_chain enables a task and a function, and spawn enables t inside a
// fork-join_none and is called from an initial procedure; both are legal. f
// enables t as a statement of its own body.
// Icarus Verilog 13.0 also reports an error for the legal call of t in the
// fork-join_none of spawn (13.4.4), so its rejection does not count.

module test_illegal_function_calls_task_beside_fork_join_none;
  int n;
  task t();
    #1 n++;
  endtask
  function int g();
    return 2;
  endfunction
  task task_chain();
    t();
    n = n + g();
  endtask
  function void spawn();
    fork
      t();
    join_none
  endfunction
  function void f();
    t();   // illegal
  endfunction
  initial begin
    task_chain();
    spawn();
    f();
  end
endmodule
