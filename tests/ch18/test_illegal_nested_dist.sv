/*
:name: test_illegal_nested_dist
:description: A dist expression shall not appear within another expression (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint uses x dist as the left operand of &&
:expected_stderr_regex: test_illegal_nested_dist\.sv:23:
// Icarus Verilog 13.0 does not support constraint declarations, so its
// error in the constraint block item list on that line does not count.
*/
// IEEE 1800-2023 §18.5: a dist expression may not appear in another
// expression; it is a complete constraint expression. Using it as the left
// operand of && is illegal. The 5.052 release of Verilator stops with an
// internal error on the dist node, not with a diagnostic of the rule.

class c_nested_dist;
  rand int x, y;
  constraint c { (x dist {0 := 1, 1 := 1}) && (y > 0); }   // illegal
endclass

module test_illegal_nested_dist;
  c_nested_dist o = new;
  initial $display("randomize=%0d", o.randomize());
endmodule
