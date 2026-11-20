/*
:name: test_illegal_final_class_specialization_extended
:description: A parameterized class declared :final cannot be extended through any of its specializations (IEEE 1800-2023 Section 8.13)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.13 8.25
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: wide_c extends the specialization fp_c #(16) of the class fp_c, which is declared :final
:expected_stderr_regex: test_illegal_final_class_specialization_extended\.sv:28:
*/
// IEEE 1800-2023 §8.13: a class declared with the final specifier shall not be
// extended, and an attempt to extend it is an error. §8.25: a specialization
// of a parameterized class is that class with values for its parameters, so
// extending fp_c #(16) extends fp_c. The specializations fp_c #(16) and
// fp_c #() are used as ordinary types, which is legal; without the extends in
// the marked header, wide_c is a class of its own and the legal design prints
// 16 8 32. The 5.054 release of Verilator rejects the marked line for this
// reason; Icarus Verilog 13.0 does not support :final and stops at the
// header of fp_c.

class :final fp_c #(int W = 8);
  bit [W-1:0] data;
endclass

class wide_c extends fp_c #(16);   // illegal: fp_c is final
  int extra;
endclass

module test_illegal_final_class_specialization_extended;
  fp_c #(16) a;
  fp_c #() b;
  wide_c w;
  initial begin
    a = new;
    b = new;
    w = new;
    $display("%0d %0d %0d", $bits(a.data), $bits(b.data), $bits(w.extra));
  end
endmodule
