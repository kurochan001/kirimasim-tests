/*
:name: test_illegal_keyword_identifier_sv2023
:description: A reserved keyword of 1800-2023 cannot be an unescaped declaration name (IEEE 1800-2023 Section 22.14.9)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: soft is a reserved keyword in the selected 1800-2023 keyword set
:expected_stderr_regex: test_illegal_keyword_identifier_sv2023\.sv:(?:20)(?::|\s)
*/
// IEEE 1800-2023 22.14.9: The selected keyword set must reserve soft; unlike
// the existing tests of words not yet reserved, this requires rejection of a
// reserved identifier.

`begin_keywords "1800-2023"
module test_illegal_keyword_identifier_sv2023;
  wire soft; // illegal
endmodule
`end_keywords
