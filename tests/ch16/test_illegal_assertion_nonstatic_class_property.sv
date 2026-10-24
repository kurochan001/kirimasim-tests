/*
:name: test_illegal_assertion_nonstatic_class_property
:description: an expression of a concurrent assertion cannot reference a non-static class property (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad references the non-static property x of the object that h refers to
:expected_stderr_regex: test_illegal_assertion_nonstatic_class_property\.sv:28:
*/
// IEEE 1800-2023 §16.6: expressions in concurrent assertions shall not
// reference non-static class properties or methods. p_s compares the static
// property C::sx, which is legal; p_bad compares h.x, a non-static property.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_assertion_nonstatic_class_property;
  class C;
    int x = 1;
    static int sx = 1;
  endclass
  logic clk = 0;
  C h = new;
  p_s: assert property (@(posedge clk) C::sx == 1);
  p_bad: assert property (@(posedge clk) h.x == 1);   // illegal
endmodule
