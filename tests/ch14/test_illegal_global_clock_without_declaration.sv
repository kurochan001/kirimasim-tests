/*
:name: test_illegal_global_clock_without_declaration
:description: $global_clock is an error in a top-level module that has no global clocking declaration, while a module below one that has it may use $global_clock (IEEE 1800-2023 Section 14.14)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $global_clock is used in the top-level module, which has no global clocking declaration
:expected_stderr_regex: test_illegal_global_clock_without_declaration\.sv:39:
*/
// IEEE 1800-2023 §14.14: $global_clock refers to the effective global
// clocking, found by looking in the enclosing instance and then in each
// parent instance; if a top-level block is reached without finding a global
// clocking declaration, the lookup ends in an error. gc_user declares none,
// but its parent gc_parent does, so @($global_clock) in p.uu resolves to gp
// and is legal. The test module is the top-level module, declares no global
// clocking, and uses @($global_clock) itself.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count. The 5.052 release of Verilator rejects $global_clock
// in gc_user as well, so its error on this line does not count.

module gc_user;
  int n = 0;
  always @($global_clock) n++;
endmodule

module gc_parent(input logic c);
  global clocking gp @(posedge c); endclocking
  gc_user uu();
endmodule

module test_illegal_global_clock_without_declaration;
  logic clk = 0;
  int m = 0;
  gc_parent p(clk);
  always @($global_clock) m++;   // illegal
endmodule
