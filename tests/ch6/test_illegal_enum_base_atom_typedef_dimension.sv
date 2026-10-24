/*
:name: test_illegal_enum_base_atom_typedef_dimension
:description: A type name of an integer atom type used as an enum base type cannot take a packed dimension (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the enum base type byte_t, a name of the integer atom type byte, is given the packed dimension [1:0]
:expected_stderr_regex: test_illegal_enum_base_atom_typedef_dimension\.sv:21:
*/
// IEEE 1800-2023 §6.19, footnote 19 of Syntax 6-5: a type name that stands
// for an integer atom type is a legal enum base type, but no packed
// dimension may be added to it. byte_t stands for byte, and the base
// byte_t [1:0] adds one.

module test_illegal_enum_base_atom_typedef_dimension;
  typedef byte byte_t;
  typedef enum byte_t [1:0] {A, B} e_t;    // illegal: dimension on an atom type name
  e_t e;
  initial e = A;
endmodule
