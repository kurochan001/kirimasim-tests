/*
:name: test_illegal_mutual_recursion_no_time_advance
:description: the instances of mutually recursive properties have to come after a positive advance in time (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_ping and p_pong instantiate each other after |->, so their recursion never advances time
:expected_stderr_regex: test_illegal_mutual_recursion_no_time_advance\.sv:(30|31|34|35|38):
*/
// IEEE 1800-2023 §16.12.17, restriction 3: for mutually recursive properties,
// all recursive instances shall come after a positive advance in time.
// p_ping instantiates p_pong and p_pong instantiates p_ping, each after
// 1'b1 |->, whose consequent starts at the same tick (§16.12.7); neither
// instance comes after an advance in time, so the cycle of the two never
// advances it (in the terms of F.7, its weight is zero). The rule is on the
// declarations, so a tool can report it at either of them or where the
// assertion instantiates p_ping.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support recursive properties and
// rejects the line of the property declaration. Their errors do not count.

module test_illegal_mutual_recursion_no_time_advance;
  logic clk = 0, x = 0;

  property p_ping(p);  // also reportable
    p and (1'b1 |-> p_pong(p));  // illegal
  endproperty

  property p_pong(p);  // also reportable
    p and (1'b1 |-> p_ping(p));  // illegal
  endproperty

  a_ping: assert property (@(posedge clk) p_ping(x));  // also reportable
endmodule
