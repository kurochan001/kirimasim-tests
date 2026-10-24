/*
:name: test_illegal_forward_typedef_never_defined
:description: a forward typedef whose name is never defined as a data type is an error (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: lost_t is declared forward as an enum and never defined
:expected_stderr_regex: test_illegal_forward_typedef_never_defined\.sv:25:
*/
// IEEE 1800-2023 §6.18: the actual type of a forward typedef shall be defined
// in the same local scope or generate block, and it is an error if the name
// does not resolve to a data type.
// ok_t is declared forward and then defined as an enum, and the legal design
// prints a value of it: 1. lost_t is declared forward as an enum, and no
// definition of it follows in the module or anywhere else.
// Icarus Verilog 13.0 and the 5.052 release accept the design.

module test_illegal_forward_typedef_never_defined;
  typedef enum ok_t;
  typedef enum {A, B} ok_t;
  typedef enum lost_t;   // illegal: never defined
  ok_t o = B;
  initial $display("%0d", o);
endmodule
