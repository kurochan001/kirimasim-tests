/*
:name: test_illegal_enum_restricted_type_parameter_default_int
:description: The default of a type parameter restricted with enum is also a type assigned to it, so a default of int is an error when the instance keeps it (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3 6.20.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter E of rd_m, declared type enum, has the default int, which the instance u keeps
:expected_stderr_regex: test_illegal_enum_restricted_type_parameter_default_int\.sv:(29|34):
*/
// IEEE 1800-2023 §6.20.3: a type parameter declared with enum before its name
// accepts only enumerated types, and it shall be an error if it is assigned a
// type that does not conform. §6.20.1: the type after = in a type parameter
// declaration is its default, the type it has when an instance does not
// override it. rd_m declares E with the default int, and its instance u does
// not override E, so E is int. A tool can report the declaration or the
// instance. With the enumerated type color_t as the default the design is
// legal and prints 2.
// The 5.054 release of Verilator accepts the design and prints 32. Icarus
// Verilog 13.0 does not support a basic type restriction on a type parameter
// and reports a syntax error on the declaration of E, one of the lines the
// test names, which does not count.

typedef enum bit [1:0] {RED, GREEN, BLUE} color_t;

module rd_m #(parameter type enum E = int) ();   // illegal: int does not conform to enum
  E v;
endmodule

module test_illegal_enum_restricted_type_parameter_default_int;
  rd_m u ();   // (or reported here)
  initial $display("%0d", $bits(u.v));
endmodule
