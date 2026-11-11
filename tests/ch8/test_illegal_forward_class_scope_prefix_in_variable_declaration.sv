/*
:name: test_illegal_forward_class_scope_prefix_in_variable_declaration
:description: a type selected through a still incomplete forward class with the scope resolution operator can only be used in a typedef, the type operator or a type parameter assignment (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23 8.27
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property bad_v of user_c is declared with the type later_c::small_t while later_c is only declared forward
:expected_stderr_regex: test_illegal_forward_class_scope_prefix_in_variable_declaration\.sv:29:
*/
// IEEE 1800-2023 §8.23: an incomplete forward type may resolve to a class
// type, but using :: to select a type with it as prefix is restricted to
// typedef declarations, the type operator and type parameter assignments.
// later_c is only declared forward (8.27) when user_c is declared: the
// typedef small_alias_t of later_c::small_t is legal, the property bad_v
// declared with later_c::small_t is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal typedef of
// later_c::small_t, so its error does not count; Verilator 5.052 accepts the
// design.

typedef class later_c;

class user_c;
  typedef later_c::small_t small_alias_t;
  small_alias_t ok_v;
  later_c::small_t bad_v;   // illegal: type selected through an incomplete type
endclass

class later_c;
  typedef bit [1:0] small_t;
endclass

module test_illegal_forward_class_scope_prefix_in_variable_declaration;
  user_c u = new;
  initial $display("%0d", $bits(u.ok_v));
endmodule
