/*
:name: test_illegal_nested_clocking
:description: Clocking blocks cannot be nested (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.7 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: one clocking block is declared inside another
:expected_stderr_regex: test_illegal_nested_clocking\.sv:21:
*/
// IEEE 1800-2023 §14.7: multiple clocking blocks cannot be nested. The inner
// block below gives the illegal declaration at line 21.

module test_illegal_nested_clocking;
  logic clk;

  clocking cb @(posedge clk);
    clocking inner @(posedge clk); endclocking
  endclocking
endmodule
