/*
:name: test_illegal_keyword_as_identifier
:description: A reserved keyword used as the name of a variable is rejected (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.6 5.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable is named with the keyword begin, which cannot be a user-defined identifier
:expected_stderr_regex: test_illegal_keyword_as_identifier\.sv:25:
*/
// IEEE 1800-2023 §5.6: a keyword (§5.6.2) cannot be used as a user-defined
// identifier. Begin and begin_count differ from the keyword begin, since
// identifiers are case sensitive and keywords are lowercase, and an escaped
// identifier \begin is not a keyword either (§5.6.1); all three are legal
// names. Only the declaration of begin itself, on the marked line, is an
// error.

module test_illegal_keyword_as_identifier;
  int Begin = 1;
  int begin_count = 2;
  int \begin = 3;
  int begin = 4;   // illegal: begin is a keyword

  initial $display("%0d %0d %0d", Begin, begin_count, \begin );
endmodule
