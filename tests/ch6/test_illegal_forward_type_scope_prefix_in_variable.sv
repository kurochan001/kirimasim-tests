/*
:name: test_illegal_forward_type_scope_prefix_in_variable
:description: a type selected with :: through an incomplete forward type can be used only in a typedef, the type operator or a type parameter assignment, not to declare a variable (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable bad_v is declared with box_c::item_t while box_c is still an incomplete forward type
:expected_stderr_regex: test_illegal_forward_type_scope_prefix_in_variable\.sv:32:
*/
// IEEE 1800-2023 §6.18: a forward typedef is incomplete before its final
// definition, and a type selected with the class scope resolution operator
// through an incomplete forward type, or through an interface-based typedef,
// shall be used only in typedef declarations, the type operator and type
// parameter assignments.
// box_c is declared forward and defined later in the module as a class with the
// type item_t. The typedef alias_t of box_c::item_t, made while box_c is
// incomplete, is legal, and the legal design prints the variable declared with
// alias_t: 7. The variable bad_v is declared with box_c::item_t directly, also
// before the definition of box_c.
// Icarus Verilog 13.0 reports syntax errors on the class scope selection
// through the forward type, the legal typedef included, which do not count. The
// 5.052 release accepts the design.

module test_illegal_forward_type_scope_prefix_in_variable;
  typedef box_c;
  typedef box_c::item_t alias_t;
  alias_t ok_v = 8'd7;
  box_c::item_t bad_v;   // illegal: incomplete forward type as a prefix in a variable declaration
  class box_c;
    typedef byte item_t;
  endclass
  initial $display("%0d", ok_v);
endmodule
