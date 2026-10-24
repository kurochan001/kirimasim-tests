/*
:name: test_illegal_type_parameter_base_not_class
:description: a type parameter used as the base class has to resolve to a class type after elaboration (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.25 8.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specialization wrap_c #(int) makes the base class of wrap_c the type int
:expected_stderr_regex: test_illegal_type_parameter_base_not_class\.sv:(26|32):
*/
// IEEE 1800-2023 §8.25: when a type parameter or a typedef name is used as a
// base class, it shall resolve to a class type after elaboration. wrap_c
// extends its type parameter B. The specialization with base_c is legal; the
// one with int gives a base that is not a class. A tool can report the
// specialization or the extends clause.
// Icarus Verilog 13.0 gives a syntax error at the class that extends its type
// parameter, a construct it does not parse, so its error does not count.

class base_c;
  int v = 1;
endclass

class wrap_c #(type B = base_c) extends B;   // (or reported here)
  int w = 2;
endclass

module test_illegal_type_parameter_base_not_class;
  wrap_c #(base_c) ok_h;
  wrap_c #(int) bad_h;   // illegal: the base class would be int

  initial begin
    ok_h = new;
    $display("%0d %0d", ok_h.v, ok_h.w);
  end
endmodule
