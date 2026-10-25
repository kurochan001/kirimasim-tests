/*
:name: test_illegal_recursive_property_s_nexttime
:description: the strong operator s_nexttime cannot be applied to an instance of a recursive property (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the strong operator s_nexttime is applied to an instance of the recursive property p_hold
:expected_stderr_regex: test_illegal_recursive_property_s_nexttime\.sv:32:
*/
// IEEE 1800-2023 §16.12.17, restriction 1: the strong operators, among them
// s_nexttime (§16.12.10), shall not be applied to a property expression that
// instantiates a recursive property, any more than not. p_hold(p) needs p at
// every tick; it instantiates itself after 1'b1 |=>, so it is recursive,
// and it is legal. The assertion applies s_nexttime to an instance of it.
// Applying the weak nexttime to it would be legal.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support s_nexttime and rejects the
// line of the assertion for that reason. Their errors do not count.

module test_illegal_recursive_property_s_nexttime;
  logic clk = 0, go = 0, x = 0, y = 0;

  property p_hold(p);
    p and (1'b1 |=> p_hold(p));
  endproperty

  a_strong: assert property (@(posedge clk) go |-> s_nexttime p_hold(x));  // illegal
endmodule
