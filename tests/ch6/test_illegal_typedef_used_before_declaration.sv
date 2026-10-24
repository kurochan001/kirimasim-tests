/*
:name: test_illegal_typedef_used_before_declaration
:description: the declaration of a user-defined type has to come before any reference to its name (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable late is declared with the type name late_t on the line before the typedef of late_t
:expected_stderr_regex: test_illegal_typedef_used_before_declaration\.sv:24:
*/
// IEEE 1800-2023 §6.18: the declaration of a user-defined data type shall
// precede any reference to its type identifier. early_t is declared before
// the variable that uses it; the variable late uses late_t, whose typedef is
// on the next line, in the same module.
// Icarus Verilog 13.0 reports a syntax error on that line, as it does for
// any unknown name used as a type.

module test_illegal_typedef_used_before_declaration;
  typedef logic [3:0] early_t;
  early_t early;
  late_t late;   // illegal: late_t is declared only on the next line
  typedef logic [7:0] late_t;
endmodule
