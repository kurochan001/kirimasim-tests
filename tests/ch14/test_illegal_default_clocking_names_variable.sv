/*
:name: test_illegal_default_clocking_names_variable
:description: the identifier of a default clocking statement has to name a clocking block, not a variable (IEEE 1800-2023 Section 14.12)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default clocking statement names the variable v
:expected_stderr_regex: test_illegal_default_clocking_names_variable\.sv:36:
*/
// IEEE 1800-2023 §14.12: default clocking followed by an identifier makes an
// existing clocking block the default, and the identifier shall be the name
// of a clocking block. In dc_named_ok, default clocking cb2 names the
// clocking block cb2, which is legal. The test module declares the clocking
// block cb and the variable v, and its only default clocking statement names
// v. Each module has one default clocking statement, so the rule of a single
// default clocking per module is not involved.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

module dc_named_ok(input logic clk);
  clocking cb2 @(posedge clk);
  endclocking
  default clocking cb2;
endmodule

module test_illegal_default_clocking_names_variable;
  logic clk = 0;
  logic v = 0;
  dc_named_ok u(clk);
  clocking cb @(posedge clk);
  endclocking
  default clocking v;   // illegal
endmodule
