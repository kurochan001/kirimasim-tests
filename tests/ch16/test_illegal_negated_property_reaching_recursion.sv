/*
:name: test_illegal_negated_property_reaching_recursion
:description: not cannot be applied to an instance of a nonrecursive property that instantiates a recursive property (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.3 F.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: not is applied to an instance of p_after, from which the recursive property p_hold is reached
:expected_stderr_regex: test_illegal_negated_property_reaching_recursion\.sv:38:
*/
// IEEE 1800-2023 §16.12.17, restriction 1: not (§16.12.3) shall not be
// applied to a property expression that instantiates a property depending on
// a recursive property; F.7 makes this precise: one from which a recursive
// property can be reached in the digraph of which property instantiates
// which. p_hold is recursive and legal; p_after is not recursive, but its
// declaration instantiates p_hold. The assertion negates an instance of
// p_after; the negation of a property that reaches no recursive one would be
// legal.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support recursive properties and
// rejects the line of the property declaration. Their errors do not count.

module test_illegal_negated_property_reaching_recursion;
  logic clk = 0, go = 0, x = 0;

  property p_hold(p);
    p and (1'b1 |=> p_hold(p));
  endproperty

  property p_after(s, p);
    s |=> p_hold(p);
  endproperty

  a_neg: assert property (@(posedge clk) not p_after(go, x));  // illegal
endmodule
