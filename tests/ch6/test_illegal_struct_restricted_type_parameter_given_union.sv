/*
:name: test_illegal_struct_restricted_type_parameter_given_union
:description: a type parameter restricted with the struct keyword can be given only a structure type; a packed union of the same width is an error (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter S of the instance bad, declared type struct, is overridden with the packed union word_u
:expected_stderr_regex: test_illegal_struct_restricted_type_parameter_given_union\.sv:(31|37):
*/
// IEEE 1800-2023 §6.20.3: a type parameter declared with the keyword struct
// before its name accepts only structure types, and it is an error to give
// it a type that does not conform. The module struct_param_m has S declared
// type struct with the default pair_t. The instance ok overrides it with the
// packed structure quad_t of 32 bits, which is legal, and the legal design
// prints $bits of the variable of type S in ok: 32. The instance bad gives the
// packed union word_u, also of 32 bits: the same width does not make a union
// a structure. A tool can report the override or the declaration of S.
// The 5.052 release of Verilator rejects the override for this reason.
// Icarus Verilog 13.0 does not support a basic type restriction on a type
// parameter and reports a syntax error on the declaration of S, one of the
// lines the test names, which does not count.

typedef struct packed { byte hi; byte lo; } pair_t;
typedef struct packed { byte a, b, c, d; } quad_t;
typedef union packed { int i; quad_t q; } word_u;

module struct_param_m #(parameter type struct S = pair_t) ();   // (or reported here)
  S v;
endmodule

module test_illegal_struct_restricted_type_parameter_given_union;
  struct_param_m #(.S(quad_t)) ok ();
  struct_param_m #(.S(word_u)) bad ();   // illegal: a union for a struct type parameter
  initial $display("%0d", $bits(ok.v));
endmodule
