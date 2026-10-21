/*
:name: test_illegal_final_class_extended
:description: A class declared :final cannot be extended (IEEE 1800-2023 Section 8.13)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.13 8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a class extends a class declared :final
:expected_stderr_regex: test_illegal_final_class_extended\.sv:24:
*/
// IEEE 1800-2023 §8.13: the final specifier, :final after the keyword class
// (§8.3), says that the class shall not be extended.
// Icarus Verilog 13.0 does not support :final and stops with a syntax error on
// the base class.

class :final test_illegal_final_class_extended_base;
  int v = 1;
endclass

class test_illegal_final_class_extended_derived
    extends test_illegal_final_class_extended_base;   // illegal
  int w = 2;
endclass

module test_illegal_final_class_extended;
  test_illegal_final_class_extended_derived d = new;
  initial $display("v=%0d w=%0d", d.v, d.w);
endmodule
