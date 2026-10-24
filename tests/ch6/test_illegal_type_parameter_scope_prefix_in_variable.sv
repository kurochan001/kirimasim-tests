/*
:name: test_illegal_type_parameter_scope_prefix_in_variable
:description: a type selected with :: through a type parameter can be used in a typedef or a type parameter assignment, but not directly in a variable declaration (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property bad of holder_c is declared with C::item_t, selected through the type parameter C
:expected_stderr_regex: test_illegal_type_parameter_scope_prefix_in_variable\.sv:36:
*/
// IEEE 1800-2023 §6.20.3: while type parameters may resolve to class types, a
// type selected with the class scope resolution operator through such a prefix
// shall be used only in typedef declarations, the type operator and type
// parameter assignments.
// The class holder_c has the type parameter C; it names C::item_t in the local
// type parameter assignment item_t and in the typedef alias_t, which are legal,
// and declares the properties a and b with them. The legal design specializes
// holder_c with box_c, whose item_t is byte, and prints the sizes of a and b: 8
// 8. The property bad is declared with C::item_t directly.
// Icarus Verilog 13.0 does not support class type parameters and reports a
// syntax error on the declaration of holder_c, which does not count. The 5.052
// release accepts the design.

class box_c;
  typedef byte item_t;
endclass

class holder_c #(type C = box_c);
  localparam type item_t = C::item_t;
  typedef C::item_t alias_t;
  item_t a;
  alias_t b;
  C::item_t bad;   // illegal: a type selected through a type parameter in a declaration
endclass

module test_illegal_type_parameter_scope_prefix_in_variable;
  holder_c #(box_c) h;
  initial begin
    h = new;
    $display("%0d %0d", $bits(h.a), $bits(h.b));
  end
endmodule
