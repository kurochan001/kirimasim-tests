/*
:name: test_illegal_type_parameter_scope_prefix_in_variable_declaration
:description: a type selected through a type parameter prefix with the scope resolution operator can only be used in a typedef, the type operator or a type parameter assignment (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23 6.20.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property bad_v of user_c is declared with the type T::nib_t, selected through the type parameter T
:expected_stderr_regex: test_illegal_type_parameter_scope_prefix_in_variable_declaration\.sv:36:
*/
// IEEE 1800-2023 §8.23: a type parameter may resolve to a class type, but
// using :: to select a type with a type parameter as prefix is restricted to
// typedef declarations, the type operator and type parameter assignments.
// user_c selects nib_t through its type parameter T legally in a typedef, in
// the type operator and in the specialization holder_c #(T::nib_t); the
// declaration of bad_v uses T::nib_t directly as its type.
// Icarus Verilog 13.0 stops with a syntax error at the declaration of the
// parameterized class holder_c, and Verilator 5.052 accepts the design.

class types_c;
  typedef logic [3:0] nib_t;
endclass

class holder_c #(type E = int);
  E e;
endclass

class user_c #(type T = types_c);
  typedef T::nib_t nib_alias_t;
  nib_alias_t ok_v;
  var type(T::nib_t) ok_w;
  holder_c #(T::nib_t) ok_h;
  T::nib_t bad_v;   // illegal: type selected through a type parameter
endclass

module test_illegal_type_parameter_scope_prefix_in_variable_declaration;
  user_c #(types_c) u = new;
  initial $display("%0d", $bits(u.ok_v));
endmodule
