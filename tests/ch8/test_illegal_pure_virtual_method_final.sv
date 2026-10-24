/*
:name: test_illegal_pure_virtual_method_final
:description: a pure virtual method cannot be declared with the final specifier (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure virtual method h is declared with :final
:expected_stderr_regex: test_illegal_pure_virtual_method_final\.sv:33:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 8): it shall be illegal to use the
// final specifier :final when declaring a pure virtual method or a pure
// constraint.
// The abstract class declares the pure virtual method f without :final and the
// virtual method g with :final and a body, which are legal, and a static
// function, which the legal design calls through the class scope and prints: 2.
// The pure virtual method h is declared with :final. No class is derived from
// it, so no implementation of h is needed.
// Icarus Verilog 13.0 reports syntax errors on the pure virtual method
// declarations, which do not count.

virtual class test_illegal_pure_virtual_method_final_base;
  pure virtual function int f();
  virtual function :final int g();
    return 3;
  endfunction
  static function int two();
    return 2;
  endfunction
  pure virtual function :final int h();   // illegal: pure virtual method declared final
endclass

module test_illegal_pure_virtual_method_final;
  initial $display("%0d", test_illegal_pure_virtual_method_final_base::two());
endmodule
