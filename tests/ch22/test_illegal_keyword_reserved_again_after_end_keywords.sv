/*
:name: test_illegal_keyword_reserved_again_after_end_keywords
:description: A `begin_keywords affects the source code that follows it only until the matching `end_keywords, so logic, an ordinary name under the IEEE 1364-2005 keywords, is a reserved keyword again after the `end_keywords and cannot name a variable there (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: after the `end_keywords that matches `begin_keywords "1364-2005", the keywords of IEEE Std 1800-2023 apply again and logic, a reserved keyword there, is used as the name of a variable
:expected_stderr_regex: test_illegal_keyword_reserved_again_after_end_keywords\.sv:38:
*/
// IEEE 1800-2023 §22.14: `begin_keywords affects all source code that
// follows it until the matching `end_keywords; the pairs can be nested,
// and each `end_keywords returns to the version that was in effect before
// its `begin_keywords. The outer pair selects the keywords of IEEE Std
// 1800-2023, so the result does not depend on the default keywords of the
// tool. Inside it, the inner pair selects IEEE Std 1364-2005, which does not
// reserve logic (22.14.5), and the module kw_inner_2005 legally names a
// variable logic. After the inner `end_keywords the 1800-2023 keywords,
// which reserve logic (22.14.9), apply again, and the same declaration in
// the module kw_after_end is the only error. A tool that kept the
// 1364-2005 keywords after their `end_keywords would accept the design.
// Icarus Verilog 13.0 warns that it does not know the specifier 1800-2023
// and ignores it; its own keywords, which reserve logic, then apply after
// the inner `end_keywords, so it reports the error on the same line.

`begin_keywords "1800-2023"
`begin_keywords "1364-2005"
module kw_inner_2005;
  reg [3:0] logic;
  initial logic = 4'd5;
endmodule
`end_keywords

module kw_after_end;
  reg [3:0] logic;  // illegal: logic is a keyword of IEEE Std 1800-2023
endmodule
`end_keywords

module test_illegal_keyword_reserved_again_after_end_keywords;
  kw_inner_2005 u1();
  kw_after_end u2();
endmodule
