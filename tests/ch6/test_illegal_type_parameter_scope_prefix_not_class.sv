/*
:name: test_illegal_type_parameter_scope_prefix_not_class
:description: a type parameter used as the prefix of the class scope resolution operator has to resolve to a class (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the specialization bad_t gives the type parameter C, used as the prefix of C::item_t, the type int
:expected_stderr_regex: test_illegal_type_parameter_scope_prefix_not_class\.sv:(31|35):
*/
// IEEE 1800-2023 §6.20.3: a type parameter can resolve to a class type and be
// the prefix of the class scope resolution operator in a typedef declaration,
// the type operator or a type parameter assignment, and it shall be an error if
// the prefix does not resolve to a class.
// The class holder_c has the type parameter C and the typedef item_t of
// C::item_t. The specialization ok_t with the class box_c, whose item_t is
// byte, is legal, and the legal design prints the size of a variable of its
// item_t: 8. The specialization bad_t gives C the type int, which is not a
// class. A tool can report the specialization or the typedef in holder_c.
// Icarus Verilog 13.0 does not support class type parameters and reports a
// syntax error on the declaration of holder_c, which does not count.

class box_c;
  typedef byte item_t;
endclass

class holder_c #(type C = box_c);
  typedef C::item_t item_t;   // (or reported here)
endclass

typedef holder_c #(box_c) ok_t;
typedef holder_c #(int) bad_t;   // illegal: the prefix C resolves to int

module test_illegal_type_parameter_scope_prefix_not_class;
  ok_t::item_t v;
  initial $display("%0d", $bits(v));
endmodule
