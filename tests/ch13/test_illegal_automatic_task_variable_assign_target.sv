/*
:name: test_illegal_automatic_task_variable_assign_target
:description: a variable of an automatic task cannot be the target of a procedural assign (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the automatic task variable v is the target of a procedural continuous assign
:expected_stderr_regex: test_illegal_automatic_task_variable_assign_target\.sv:23:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be assigned
// values with procedural continuous assignments. The static variable s is the
// target of an assign; the automatic v is the target of the second one.

module test_illegal_automatic_task_variable_assign_target;
  int s;
  task automatic t(input int a);
    int v;
    assign s = 1;
    assign v = 1;   // illegal
  endtask
  initial t(1);
endmodule
