/*
:name: test_illegal_enum_base_packed_struct_typedef
:description: A type name used as an enum base type must stand for an integer atom type or an integer vector type, not for a packed structure (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.19 7.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the enum base type nib_t is a packed structure type, which is neither an integer atom type nor an integer vector type
:expected_stderr_regex: test_illegal_enum_base_packed_struct_typedef\.sv:21:
*/
// IEEE 1800-2023 §6.19, Syntax 6-5 and its footnote 19: a type name is a
// legal enum base type only when it stands for an integer atom type or an
// integer vector type (bit, logic, reg). nib_t is a packed structure
// (§7.2.1); it is integral, but it is not one of those types.

module test_illegal_enum_base_packed_struct_typedef;
  typedef struct packed { bit [1:0] hi; bit [1:0] lo; } nib_t;
  typedef enum nib_t {A, B} e_t;    // illegal: packed structure as base type
  e_t e;
  initial e = A;
endmodule
