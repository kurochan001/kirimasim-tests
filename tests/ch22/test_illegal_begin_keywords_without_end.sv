/*
:name: test_illegal_begin_keywords_without_end
:description: `begin_keywords and `end_keywords are used as a pair, so a `begin_keywords that no `end_keywords follows is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the last `begin_keywords of the file is not followed by an `end_keywords
:expected_stderr_regex: test_illegal_begin_keywords_without_end\.sv:(26|27):
*/
// IEEE 1800-2023 §22.14: `begin_keywords and `end_keywords shall be used as
// a pair, with `end_keywords appearing some time after `begin_keywords.
// The first pair below is complete; the `begin_keywords on the last line
// of the file is never ended. A tool can report it there or at the end of
// the file, just after that line.
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052.

`begin_keywords "1800-2012"
module test_illegal_begin_keywords_without_end;
endmodule
`end_keywords

`begin_keywords "1800-2012"  // illegal: never ended
