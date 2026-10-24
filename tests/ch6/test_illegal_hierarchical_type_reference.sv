/*
:name: test_illegal_hierarchical_type_reference
:description: a type identifier of a module instance cannot be referenced with a hierarchical name, while a type of an interface reached through a port can be redefined locally (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the typedef word_alias_t refers to the type word_t of the module instance c through the hierarchical name c.word_t
:expected_stderr_regex: test_illegal_hierarchical_type_reference\.sv:48:
*/
// IEEE 1800-2023 §6.18: user-defined type identifiers have the same scoping
// rules as data identifiers, except that hierarchical references to type
// identifiers shall not be allowed. A reference to a type of an interface
// through a port, redefined locally by a typedef (an interface-based typedef),
// is not a hierarchical reference and is allowed.
// The module user_m redefines the type nib_t of the interface connected to its
// port p as local_nib_t, which is legal, and the legal design prints a variable
// of that type through the instance u and the variable w of the instance c,
// both through hierarchical names of variables: 5 9. The typedef word_alias_t
// names the type word_t of the module instance c through the hierarchical name
// c.word_t.
// Icarus Verilog 13.0 does not support the interface port and the
// interface-based typedef of user_m and reports syntax errors on them, which do
// not count.

interface test_illegal_hierarchical_type_reference_if;
  typedef logic [3:0] nib_t;
endinterface

module test_illegal_hierarchical_type_reference_child;
  typedef logic [5:0] word_t;
  word_t w = 6'd9;
endmodule

module test_illegal_hierarchical_type_reference_user_m (
    test_illegal_hierarchical_type_reference_if p);
  typedef p.nib_t local_nib_t;
  local_nib_t n = 4'd5;
endmodule

module test_illegal_hierarchical_type_reference;
  test_illegal_hierarchical_type_reference_if i ();
  test_illegal_hierarchical_type_reference_user_m u (.p(i));
  test_illegal_hierarchical_type_reference_child c ();
  typedef c.word_t word_alias_t;   // illegal: hierarchical reference to a type
  initial $display("%0d %0d", u.n, c.w);
endmodule
