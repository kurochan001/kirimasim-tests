/*
:name: test_illegal_automatic_task_variable_in_force_expression
:description: a variable of an automatic task cannot be referenced by force (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the force of s reads the automatic task variable v
:expected_stderr_regex: test_illegal_automatic_task_variable_in_force_expression\.sv:26:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be
// referenced by assign or force procedural continuous assignments. The first
// force reads the static variable g, which is legal; the second reads the
// automatic v.
// The 5.052 release of Verilator accepts the design.

module test_illegal_automatic_task_variable_in_force_expression;
  int s, g;
  task automatic t(input int a);
    int v;
    v = a;
    force s = g;
    force s = v + 1;   // illegal
  endtask
  initial t(1);
endmodule
