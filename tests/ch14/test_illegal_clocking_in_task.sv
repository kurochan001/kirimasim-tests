/*
:name: test_illegal_clocking_in_task
:description: A clocking block cannot be declared in a task (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a clocking block is declared inside a task
:expected_stderr_regex: test_illegal_clocking_in_task\.sv:20:
*/
// IEEE 1800-2023 §14.7: a clocking block is static and local to a module,
// interface, checker or program, so it cannot be declared in a task. The task
// below gives the illegal declaration at line 20.

module test_illegal_clocking_in_task;
  task automatic t();
    clocking cb @(posedge clk); endclocking
  endtask
endmodule
