/*
:name: test_illegal_assertion_chandle_variable
:description: an expression of a concurrent assertion cannot reference a chandle variable (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad compares the chandle variable ch with null
:expected_stderr_regex: test_illegal_assertion_chandle_variable\.sv:27:
*/
// IEEE 1800-2023 §16.6: expressions in concurrent assertions shall not
// reference variables of the chandle data type. p_ok compares the bit b;
// p_bad compares the chandle ch with null, which a procedural statement
// may do (6.14), as the initial procedure does.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_assertion_chandle_variable;
  logic clk = 0;
  bit b;
  chandle ch;
  initial if (ch == null) $display("null");
  p_ok: assert property (@(posedge clk) b == 0);
  p_bad: assert property (@(posedge clk) ch == null);   // illegal
endmodule
