/*
:name: test_illegal_end_keywords_without_begin
:description: `begin_keywords and `end_keywords are used as a pair with `begin_keywords first, so an `end_keywords with no `begin_keywords before it is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second `end_keywords has no `begin_keywords before it that it could end
:expected_stderr_regex: test_illegal_end_keywords_without_begin\.sv:26:
*/
// IEEE 1800-2023 §22.14: `begin_keywords and `end_keywords shall be used as
// a pair, `begin_keywords first and `end_keywords later. The first pair
// below is complete; the second `end_keywords has no `begin_keywords left
// to close.
// Icarus Verilog 13.0 only warns about the unmatched `end_keywords, and
// the design is accepted by Verilator 5.052.

`begin_keywords "1800-2012"
module test_illegal_end_keywords_without_begin;
endmodule
`end_keywords

`end_keywords  // illegal: no begin_keywords to end
