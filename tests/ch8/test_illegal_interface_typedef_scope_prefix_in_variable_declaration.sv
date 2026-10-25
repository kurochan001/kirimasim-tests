/*
:name: test_illegal_interface_typedef_scope_prefix_in_variable_declaration
:description: a type selected through a class type given by an interface-based typedef with the scope resolution operator can only be used in a typedef, the type operator or a type parameter assignment (IEEE 1800-2023 Section 8.23)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.23 6.18
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable bad_v of user_m is declared with pay_t::data_t, where pay_t is an interface-based typedef
:expected_stderr_regex: test_illegal_interface_typedef_scope_prefix_in_variable_declaration\.sv:34:
*/
// IEEE 1800-2023 §8.23: a type defined by an interface-based typedef (6.18)
// may resolve to a class type, but using :: to select a type with it as
// prefix is restricted to typedef declarations, the type operator and type
// parameter assignments. pay_t is the class pay_c of the interface reached
// through the port p; the typedef data_alias_t of pay_t::data_t is legal,
// the variable bad_v declared with pay_t::data_t is not.
// Icarus Verilog 13.0 gives syntax errors also on the legal interface-based
// typedefs, so its error does not count; Verilator 5.052 stops with an internal
// error.

interface types_if;
  class pay_c;
    typedef byte data_t;
  endclass
endinterface

module user_m (types_if p);
  typedef p.pay_c pay_t;
  typedef pay_t::data_t data_alias_t;
  data_alias_t ok_v = 8'd5;
  pay_t::data_t bad_v;   // illegal: type selected through an interface-based typedef
endmodule

module test_illegal_interface_typedef_scope_prefix_in_variable_declaration;
  types_if ti ();
  user_m u (.p(ti));
  initial $display("%0d", u.ok_v);
endmodule
