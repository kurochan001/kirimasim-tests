/*
:name: test_illegal_forward_enum_defined_as_struct
:description: when a forward typedef names the basic type enum, the final definition has to be an enum; a structure is an error (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: mode_t is declared forward as an enum but defined as a packed structure
:expected_stderr_regex: test_illegal_forward_enum_defined_as_struct\.sv:(31|39):
*/
// IEEE 1800-2023 §6.18: the actual type of a forward typedef shall be defined
// in the same local scope or generate block; it is an error if the name does
// not resolve to a data type, and an error if the forward declaration names a
// basic type (enum, struct, union, class or interface class) that the final
// definition does not have. Forward declarations may come before or after the
// definition.
// ok_t is declared forward as an enum and defined as an enum, pair_t forward as
// a struct and defined as a packed structure, and any_t forward without a basic
// type and defined as int; the legal design prints a value of each: 1 5a 7.
// mode_t is declared forward as an enum and defined as a packed structure. A
// tool can report the forward declaration or the definition.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

module test_illegal_forward_enum_defined_as_struct;
  typedef enum ok_t;
  typedef struct pair_t;
  typedef any_t;
  typedef enum mode_t;   // (or reported here)
  typedef enum bit [1:0] {LOW, HIGH} ok_t;
  typedef struct packed { bit [3:0] a, b; } pair_t;
  typedef int any_t;
  ok_t m = HIGH;
  pair_t p = 8'h5a;
  any_t n = 7;
  initial $display("%0d %h %0d", m, p, n);
  typedef struct packed { bit [1:0] f; } mode_t;   // illegal: enum forward, struct definition
endmodule
