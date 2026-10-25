/*
:name: test_illegal_hierarchical_read_into_checker
:description: Hierarchical references into a checker are not permitted, so a module cannot read a checker variable through a hierarchical name (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module reads the variable armed of the checker instance c through the hierarchical name c.armed
:expected_stderr_regex: test_illegal_hierarchical_read_into_checker\.sv:29:
*/
// IEEE 1800-2023 §23.6: hierarchical references into checkers (§17.2)
// shall not be permitted. The module only reads the checker variable
// c.armed in a $display, so the reference itself, not an assignment, is
// what the design breaks; the rest of the design is legal.
// Icarus Verilog 13.0 does not support checkers, and Verilator 5.052
// accepts the design.

checker hierarchical_read_into_checker_chk(logic a, logic clk);
  bit armed = 1'b1;
  p: assert property (@(posedge clk) armed |-> a);
endchecker

module test_illegal_hierarchical_read_into_checker;
  logic clk = 1'b0, a = 1'b1;
  hierarchical_read_into_checker_chk c(a, clk);
  initial #1 $display("armed=%b", c.armed);   // illegal
endmodule
