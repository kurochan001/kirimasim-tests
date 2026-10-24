/*
:name: test_illegal_assertion_nonstatic_class_method
:description: an expression of a concurrent assertion cannot call a non-static class method (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad calls the non-static method get of the object that h refers to
:expected_stderr_regex: test_illegal_assertion_nonstatic_class_method\.sv:35:
*/
// IEEE 1800-2023 §16.6: expressions in concurrent assertions shall not
// reference non-static class properties or methods. p_s calls the static
// method C::sget, which is legal; p_bad calls h.get(), a non-static method.
// Both methods are automatic, read a value and have no side effects.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_assertion_nonstatic_class_method;
  class C;
    int x = 1;
    static int sx = 1;
    function int get();
      return x;
    endfunction
    static function int sget();
      return sx;
    endfunction
  endclass
  logic clk = 0;
  C h = new;
  p_s: assert property (@(posedge clk) C::sget() == 1);
  p_bad: assert property (@(posedge clk) h.get() == 1);   // illegal
endmodule
