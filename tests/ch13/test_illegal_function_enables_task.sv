/*
:name: test_illegal_function_enables_task
:description: A function cannot enable a task, even one without timing controls (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function f calls the task t
:expected_stderr_regex: test_illegal_function_enables_task\.sv:24:
*/
// IEEE 1800-2023 §13.4: a function cannot enable tasks, whether or not the task
// has time-controlling statements. t has none, but calling it from f is still
// illegal.

module test_illegal_function_enables_task;
  int n;
  task t();
    n = 1;
  endtask
  function void f();
    t();               // illegal: a function enables a task
  endfunction
  initial f();
endmodule
