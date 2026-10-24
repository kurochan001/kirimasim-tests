/*
:name: test_illegal_automatic_task_variable_nonblocking_target
:description: a variable of an automatic task cannot be the target of a nonblocking assignment (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the automatic task variable v is assigned with a nonblocking assignment
:expected_stderr_regex: test_illegal_automatic_task_variable_nonblocking_target\.sv:23:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task are deallocated when
// the call ends, so they shall not be assigned with nonblocking assignments.
// The static variable s may be; the automatic v may not.

module test_illegal_automatic_task_variable_nonblocking_target;
  int s;
  task automatic t(input int a);
    int v;
    s <= a;
    v <= a;   // illegal
  endtask
  initial t(1);
endmodule
