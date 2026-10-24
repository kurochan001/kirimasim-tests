/*
:name: test_illegal_local_variable_initializer_uses_uninitialized
:description: the initialization of a local variable may use an earlier local variable only if that one has an initialization assignment too (IEEE 1800-2023 Section 16.10)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initialization of v in p_bad uses the earlier local variable u, which has no initialization assignment
:expected_stderr_regex: test_illegal_local_variable_initializer_uses_uninitialized\.sv:30:
*/
// IEEE 1800-2023 §16.10: the expression of the initialization assignment of a
// local variable may refer to a local variable declared before it only if
// that variable has an initialization assignment itself, whose value is then
// used. In p_ok, q = p + 1 uses p, which is initialized to d; in p_bad,
// v = u + 1 uses u, which has no initialization assignment.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_local_variable_initializer_uses_uninitialized;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  property p_ok;
    int p = d, q = p + 1;
    a ##1 (c == q);
  endproperty
  property p_bad;
    int u, v = u + 1;   // illegal
    a ##1 (c == v);
  endproperty
  a_ok: assert property (@(posedge clk) p_ok);
  a_bad: assert property (@(posedge clk) p_bad);
endmodule
