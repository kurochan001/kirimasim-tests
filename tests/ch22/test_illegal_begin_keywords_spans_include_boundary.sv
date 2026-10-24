/*
:name: test_illegal_begin_keywords_spans_include_boundary
:description: A `begin_keywords in an included file stays in effect after the end of that file until the matching `end_keywords, so under the IEEE 1364-2005 keywords it selects, logic is an ordinary identifier and logic x; in the including file is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: begin_keywords_1364_2005_helper.svh
:should_fail_because: the `begin_keywords "1364-2005" of the included file is still in effect after the `include, and IEEE Std 1364-2005 does not reserve logic, so logic x; is neither a declaration nor a legal module instantiation
:expected_stderr_regex: test_illegal_begin_keywords_spans_include_boundary\.sv:31:
*/
// IEEE 1800-2023 §22.14: the `begin_keywords directive affects all source
// code that follows it, even across source code file boundaries, until the
// matching `end_keywords. The file that :files: names holds only
// `begin_keywords "1364-2005"; the matching `end_keywords is in this file
// after the module kw_after_include. IEEE Std 1364-2005 does not reserve
// logic (22.14.5), so in that module logic is an identifier, and logic x;
// would be an instantiation of a module named logic without the required
// parentheses or a declaration of a type named logic, which does not exist.
// That line is the only error: a tool that ended the effect of the
// directive at the end of the included file would read logic x; as a legal
// variable declaration. The top module follows the `end_keywords and uses
// the default keywords.

`include "begin_keywords_1364_2005_helper.svh"

module kw_after_include;
  logic x;  // illegal: logic is not a keyword of IEEE Std 1364-2005
endmodule
`end_keywords

module test_illegal_begin_keywords_spans_include_boundary;
  logic y = 1'b0;
  kw_after_include u();
endmodule
