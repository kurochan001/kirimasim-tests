/*
:name: test_illegal_global_clocking_in_generate
:description: a global clocking declaration cannot be placed in a generate block, although an ordinary clocking block can (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.14 14.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the global clocking gbad is declared in the generate block g
:expected_stderr_regex: test_illegal_global_clocking_in_generate\.sv:34:
*/
// IEEE 1800-2023 §14.14: global clocking may be declared in a module, an
// interface, a checker or a program, at most once in each, and shall not be
// declared in a generate block. gc_ok declares one global clocking directly
// in the module, which is legal. The test module declares no global clocking
// outside the generate block g, so the generate block holds the only one of
// the module and the rule of one declaration per module is not involved.
// §14.7: an ordinary clocking block may be declared in a module, and the
// clocking block cb in g is legal.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count. The 5.052 release of Verilator accepts the design.

module gc_ok(input logic c);
  global clocking gok @(posedge c); endclocking
endmodule

module test_illegal_global_clocking_in_generate;
  logic clk = 0;
  gc_ok u(clk);
  if (1) begin : g
    clocking cb @(posedge clk); endclocking
    global clocking gbad @(posedge clk); endclocking   // illegal
  end
endmodule
