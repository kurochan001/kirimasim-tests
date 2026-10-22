/*
:name: test_illegal_keyword_identifier_v2001
:description: A reserved keyword of 1364-2001 cannot be an unescaped declaration name (IEEE 1800-2023 Section 22.14.3)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: localparam is a reserved keyword in the selected 1364-2001 keyword set
:expected_stderr_regex: test_illegal_keyword_identifier_v2001\.sv:(?:20)(?::|\s)
*/
// IEEE 1800-2023 22.14.3: The selected keyword set must reserve localparam;
// unlike the existing tests of words not yet reserved, this requires rejection
// of a reserved identifier.

`begin_keywords "1364-2001"
module test_illegal_keyword_identifier_v2001;
  wire localparam; // illegal
endmodule
`end_keywords
