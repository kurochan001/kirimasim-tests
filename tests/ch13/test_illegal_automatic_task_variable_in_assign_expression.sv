/*
:name: test_illegal_automatic_task_variable_in_assign_expression
:description: a variable of an automatic task cannot be referenced by a procedural assign (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the procedural continuous assign to s reads the automatic task variable v
:expected_stderr_regex: test_illegal_automatic_task_variable_in_assign_expression\.sv:25:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be
// referenced by assign or force procedural continuous assignments. The first
// assign reads the static variable g, which is legal; the second reads the
// automatic v.

module test_illegal_automatic_task_variable_in_assign_expression;
  int s, g;
  task automatic t(input int a);
    int v;
    v = a;
    assign s = g;
    assign s = v + 1;   // illegal
  endtask
  initial t(1);
endmodule
