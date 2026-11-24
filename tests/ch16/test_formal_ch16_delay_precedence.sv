/*
:name: test_formal_ch16_delay_precedence
:description: Sequence concatenation precedes or and associates to the left
:tags: ch16
:type: formal
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:formal_case: ch16_delay_precedence
*/
// a or b ##1 1'b1 ##1 1'b1 matches at age 1 for a and age 3 for b.
// The parser tree must group the two delay operations from the left.
// Reference bits 2 and 6 contain the matches. Bit 8 records left grouping.
// formal result: PASS
