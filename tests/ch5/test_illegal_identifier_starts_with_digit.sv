/*
:name: test_illegal_identifier_starts_with_digit
:description: A simple identifier that starts with a digit is rejected (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable name 9lives starts with a digit, which a simple identifier cannot
:expected_stderr_regex: test_illegal_identifier_starts_with_digit\.sv:24:
*/
// IEEE 1800-2023 §5.6: a simple identifier is a sequence of letters, digits,
// dollar signs and underscores whose first character is a letter or an
// underscore, never a digit or $. The names _bus3, n$657 and lives9 below
// follow the rule, with a digit and a dollar sign after the first character;
// the declaration of 9lives on the marked line does not.

module test_illegal_identifier_starts_with_digit;
  int _bus3 = 1;
  int n$657 = 2;
  int lives9 = 3;
  int 9lives = 4;   // illegal: the identifier starts with a digit

  initial $display("%0d %0d %0d", _bus3, n$657, lives9);
endmodule
