/*
:name: test_illegal_recursive_property_no_time_advance
:description: an instance of a recursive property in its own declaration has to come after a positive advance in time (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the recursive instance of p_stuck follows |->, which does not advance time
:expected_stderr_regex: test_illegal_recursive_property_no_time_advance\.sv:(28|29|32):
*/
// IEEE 1800-2023 §16.12.17, restriction 3: in the declaration of a recursive
// property every instance of it shall come after a positive advance in
// time. In p_stuck the instance follows 1'b1 |->, whose consequent starts at
// the same tick (§16.12.7), so the recursion would check p again and again in
// one tick. With |=> it would be legal. The rule is on the declaration, so a
// tool can report it there or where the assertion instantiates p_stuck.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support recursive properties and
// rejects the line of the property declaration. Their errors do not count.

module test_illegal_recursive_property_no_time_advance;
  logic clk = 0, x = 0;

  property p_stuck(p);  // also reportable
    p and (1'b1 |-> p_stuck(p));  // illegal
  endproperty

  a_stuck: assert property (@(posedge clk) p_stuck(x));  // also reportable
endmodule
