/*
:name: test_illegal_recursive_property_disable_iff
:description: the declaration of a recursive property cannot contain disable iff (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the recursive property p_rec uses disable iff in its declaration
:expected_stderr_regex: test_illegal_recursive_property_disable_iff\.sv:(28|29|32):
*/
// IEEE 1800-2023 §16.12.17, restriction 2: the operator disable iff (§16.12)
// shall not be used in the declaration of a recursive property. p_rec
// instantiates itself after 1'b1 |=>, so it is recursive, and it is legal
// in every other respect; its body starts with disable iff. The rule is on
// the declaration, so a tool can report it there or where the assertion
// instantiates p_rec.
// Icarus Verilog 13.0 does not support property declarations and reports
// syntax errors from their lines on, also on the line of the assertion; the
// 5.052 release of Verilator does not support recursive properties and
// rejects the line of the property declaration. Their errors do not count.

module test_illegal_recursive_property_disable_iff;
  logic clk = 0, rst = 0, x = 0;

  property p_rec(p);  // also reportable
    disable iff (rst) p and (1'b1 |=> p_rec(p));  // illegal
  endproperty

  a_rec: assert property (@(posedge clk) p_rec(x));  // also reportable
endmodule
