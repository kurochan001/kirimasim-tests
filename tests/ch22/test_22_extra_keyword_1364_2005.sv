/*
:name: test_22_extra_keyword_1364_2005
:description: Under `begin_keywords "1364-2005" uwire is a reserved keyword, and the only word that version adds cannot be an unescaped declaration name (IEEE 1800-2023 Section 22.14.5)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: uwire is a reserved keyword in the selected 1364-2005 keyword set
:expected_stderr_regex: test_22_extra_keyword_1364_2005\.sv:24:
*/
// IEEE 1800-2023 §22.14.5: the version specifier "1364-2005" reserves the
// keywords of 1364-1995 and 1364-2001 plus the additional identifiers of
// Table 22-3, which holds only uwire. Table 22-3 is what this version adds, so
// using uwire as an unescaped declaration name is the error that separates
// 1364-2005 from 1364-2001; outside a `begin_keywords region a tool whose
// default set is 1800-2023 rejects it as well, and inside "1364-2001" it would
// be an ordinary name.

`begin_keywords "1364-2005"
module test_22_extra_keyword_1364_2005;
  wire uwire; // illegal: uwire is a keyword in 1364-2005
endmodule
`end_keywords
