/*
:name: test_illegal_two_global_clocking
:description: A module can contain at most one global clocking declaration (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares global clocking twice
:expected_stderr_regex: test_illegal_two_global_clocking\.sv:23:
*/
// IEEE 1800-2023 §14.14: a module, interface, checker or program shall
// contain at most one global clocking declaration.
// Icarus Verilog 13.0 does not support clocking blocks, so the syntax errors it
// reports, also on that line, do not count.

module test_illegal_two_global_clocking;
  logic clk1 = 0, clk2 = 0;
  global clocking g1 @(posedge clk1);
  endclocking
  global clocking g2 @(posedge clk2);   // illegal: second global clocking
  endclocking
  always #5 clk1 = ~clk1;
  always #7 clk2 = ~clk2;
  initial #30 $finish;
endmodule
