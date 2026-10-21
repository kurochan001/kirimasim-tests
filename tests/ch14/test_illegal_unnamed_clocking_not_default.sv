/*
:name: test_illegal_unnamed_clocking_not_default
:description: Only a default clocking block can be unnamed (IEEE 1800-2023 Section 14.3)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a clocking block without a name is not the default clocking
:expected_stderr_regex: test_illegal_unnamed_clocking_not_default\.sv:21:
*/
// IEEE 1800-2023 §14.3: only default clocking blocks may be unnamed.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_unnamed_clocking_not_default;
  logic clk = 0;
  logic a = 0;
  clocking @(posedge clk);   // illegal: unnamed and not default
    input a;
  endclocking
  always #5 clk = ~clk;
  initial #30 $finish;
endmodule
