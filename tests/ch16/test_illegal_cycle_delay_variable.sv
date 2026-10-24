/*
:name: test_illegal_cycle_delay_variable
:description: a cycle delay has to be a constant expression computed at compile time (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the cycle delay of p_bad is the variable n, which is not a constant expression
:expected_stderr_regex: test_illegal_cycle_delay_variable\.sv:27:
*/
// IEEE 1800-2023 §16.7: the constant_primary of a cycle delay is a constant
// expression computed at compile time, which shall result in an integer
// value, and it and the bounds of a cycle delay range shall be 0 or
// greater.
// In p_ok the delay is the parameter D; in p_bad it is the module variable n.
// Icarus Verilog 13.0 does not support concurrent assertions; the syntax
// errors it reports do not count.

module test_illegal_cycle_delay_variable;
  logic clk = 0, a = 0, b = 0;
  int n = 2;
  localparam int D = 2;
  p_ok: assert property (@(posedge clk) a |-> ##D b);
  p_bad: assert property (@(posedge clk) a |-> ##n b);   // illegal
endmodule
