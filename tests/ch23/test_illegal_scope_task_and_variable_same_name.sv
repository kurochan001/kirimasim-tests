/*
:name: test_illegal_scope_task_and_variable_same_name
:description: One identifier declares only one item in a scope, so a module cannot have a variable and a task of the same name (IEEE 1800-2023 Section 23.9)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares both a variable and a task named step
:expected_stderr_regex: test_illegal_scope_task_and_variable_same_name\.sv:27:
*/
// IEEE 1800-2023 §23.9: an identifier declares only one item within a scope;
// naming a task the same as a variable of the same module is illegal. The
// variable count and the task bump have different names and are legal; the
// task step reuses the name of the variable step.
// Oracle checks: the 5.052 release of Verilator rejects the task only as
// unsupported in its C++ output, which is not counted.

module test_illegal_scope_task_and_variable_same_name;
  int count;
  int step;
  task bump;
    count = count + 1;
  endtask
  task step;   // illegal: step is already the name of a variable
    count = count + 2;
  endtask
endmodule
