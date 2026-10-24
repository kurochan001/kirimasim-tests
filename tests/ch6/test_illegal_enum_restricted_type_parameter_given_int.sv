/*
:name: test_illegal_enum_restricted_type_parameter_given_int
:description: a type parameter restricted with the enum keyword can be given only an enumerated type; int is an error (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter E_T of the instance bad, declared type enum, is overridden with int
:expected_stderr_regex: test_illegal_enum_restricted_type_parameter_given_int\.sv:(30|36):
*/
// IEEE 1800-2023 §6.20.3: like a forward typedef, a type parameter declaration
// can restrict its valid types with the keyword enum, struct, union, class or
// interface class before its name, and it shall be an error if the parameter is
// assigned a type that does not conform to that basic type.
// The module enum_param_m has the type parameter E_T declared type enum, with
// the enumerated type color_t as its default. The instance ok overrides it with
// the enumerated type level_t of 2 bits, which is legal, and the legal design
// prints the size of a variable of E_T in ok: 2. The instance bad overrides E_T
// with int. A tool can report the override or the declaration of E_T.
// Icarus Verilog 13.0 does not support a basic type restriction on a type
// parameter and reports a syntax error on the declaration of E_T, one of the
// lines the test names, which does not count.

typedef enum bit [2:0] {RED, GREEN, BLUE} color_t;
typedef enum bit [1:0] {LOW, MID, HIGH} level_t;

module enum_param_m #(parameter type enum E_T = color_t) ();   // (or reported here)
  E_T v;
endmodule

module test_illegal_enum_restricted_type_parameter_given_int;
  enum_param_m #(.E_T(level_t)) ok ();
  enum_param_m #(.E_T(int)) bad ();   // illegal: int for a type parameter restricted to enum
  initial $display("%0d", $bits(ok.v));
endmodule
