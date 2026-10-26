/*
:name: test_illegal_action_modifies_automatic
:description: the action block of a procedural concurrent assertion modifies a captured automatic variable
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the fail action of a_bad assigns to the automatic input a of the task run
:expected_stderr_regex: test_illegal_action_modifies_automatic\.sv:23:
*/
// IEEE 1800-2023 §16.14.6.1: the values of constant and automatic variables
// used in a procedural concurrent assertion behave as inputs and shall not be
// modified. The fail action of a_bad assigns to the automatic input a, so the
// assertion is illegal.

module test_illegal_action_modifies_automatic;
  logic clk = 0;

  task automatic run(input int a);
    a_bad: assert property (@(posedge clk) a == 1) else a = 0;   // illegal
  endtask

  initial run(0);
endmodule
