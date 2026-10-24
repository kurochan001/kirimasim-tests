/*
:name: test_illegal_automatic_task_variable_force_target
:description: a variable of an automatic task cannot be the target of force (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the automatic task variable v is the target of a force statement
:expected_stderr_regex: test_illegal_automatic_task_variable_force_target\.sv:25:
*/
// IEEE 1800-2023 §13.3.2: variables of an automatic task shall not be assigned
// values with procedural continuous assignments, of which force is one. The
// static variable s is forced; the automatic v is the target of the second
// force.
// The 5.052 release of Verilator accepts the design.

module test_illegal_automatic_task_variable_force_target;
  int s;
  task automatic t(input int a);
    int v;
    force s = 1;
    force v = 1;   // illegal
  endtask
  initial t(1);
endmodule
