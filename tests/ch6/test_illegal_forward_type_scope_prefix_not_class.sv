/*
:name: test_illegal_forward_type_scope_prefix_not_class
:description: a forward type used as the prefix of the class scope resolution operator has to resolve to a class (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: holder_t, declared forward and used as the prefix of holder_t::item_t, is defined as int, not as a class
:expected_stderr_regex: test_illegal_forward_type_scope_prefix_not_class\.sv:(33|34):
*/
// IEEE 1800-2023 §6.18: a type can be selected with the class scope resolution
// operator through an incomplete forward type in a typedef declaration, and it
// shall be an error if the prefix does not resolve to a class.
// box_c is declared forward, the typedef ok_t selects box_c::item_t, and box_c
// is then defined as a class with the type item_t; the legal design prints a
// variable of ok_t: 7. holder_t is declared forward, the typedef bad_t selects
// holder_t::item_t, and holder_t is then defined as int. A tool can report the
// typedef or the definition.
// Icarus Verilog 13.0 reports syntax errors on the class scope selection
// through the forward types, the legal typedef included, which do not count.

module test_illegal_forward_type_scope_prefix_not_class;
  typedef box_c;
  typedef box_c::item_t ok_t;
  class box_c;
    typedef byte item_t;
  endclass
  ok_t ok_v = 8'd7;
  typedef holder_t;
  typedef holder_t::item_t bad_t;   // illegal: the prefix resolves to int, not to a class
  typedef int holder_t;   // (or reported here)
  initial $display("%0d", ok_v);
endmodule
