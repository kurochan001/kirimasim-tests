/*
:name: test_illegal_parameterized_class_without_default_specialization
:description: the unadorned name of a parameterized class with a parameter that has no default does not denote a specialization (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: need_c has a parameter without a default, so need_c alone has no default specialization to declare bad_h with
:expected_stderr_regex: test_illegal_parameterized_class_without_default_specialization\.sv:33:
*/
// IEEE 1800-2023 §8.25: the unadorned name of a parameterized class denotes
// its default specialization, C#(). A class may leave a parameter without a
// default, and then it has no default specialization: every specialization
// shall override at least those parameters. has_c alone and need_c #(4) are
// legal; need_c alone is not.
// Icarus Verilog 13.0 stops with a syntax error at the first parameterized
// class declaration.

class has_c #(int depth = 2);
  int d = depth;
endclass

class need_c #(int depth);
  int d = depth;
endclass

module test_illegal_parameterized_class_without_default_specialization;
  has_c ok_a;
  need_c #(4) ok_b;
  need_c bad_h;   // illegal: need_c has no default specialization

  initial begin
    ok_a = new;
    ok_b = new;
    $display("%0d %0d", ok_a.d, ok_b.d);
  end
endmodule
