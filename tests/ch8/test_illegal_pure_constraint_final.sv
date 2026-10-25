/*
:name: test_illegal_pure_constraint_final
:description: a pure constraint cannot be declared with the final specifier (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure constraint c2 is declared with :final
:expected_stderr_regex: test_illegal_pure_constraint_final\.sv:34:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 8): it shall be illegal to use the
// final specifier :final when declaring a pure virtual method or a pure
// constraint.
// The abstract class declares the pure constraint c1 without :final and the
// constraint limit with :final and a body, which are legal, and a static
// function, which the legal design calls through the class scope and prints: 2.
// The pure constraint c2 is declared with :final. No class is derived from it,
// so no constraint c2 has to be given.
// Icarus Verilog 13.0 reports syntax errors on the constraint declarations,
// which do not count. The 5.052 release does not accept an override specifier
// on any constraint prototype, the legal pure constraint :initial included, so
// its syntax error on the line of c2 does not count.

virtual class test_illegal_pure_constraint_final_base;
  rand bit [3:0] x;
  pure constraint c1;
  constraint :final limit { x < 8; }
  static function int two();
    return 2;
  endfunction
  pure constraint :final c2;   // illegal: pure constraint declared final
endclass

module test_illegal_pure_constraint_final;
  initial $display("%0d", test_illegal_pure_constraint_final_base::two());
endmodule
