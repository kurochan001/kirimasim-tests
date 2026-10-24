/*
:name: test_illegal_begin_keywords_survives_resetall
:description: The results of `begin_keywords are not affected by `resetall, so after `begin_keywords "1364-2005" and `resetall, logic is still an ordinary identifier and logic x; is an error (IEEE 1800-2023 Section 22.14)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.14
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: `resetall does not end the `begin_keywords "1364-2005" before it, and IEEE Std 1364-2005 does not reserve logic, so logic x; is neither a declaration nor a legal module instantiation
:expected_stderr_regex: test_illegal_begin_keywords_survives_resetall\.sv:29:
*/
// IEEE 1800-2023 §22.14: the results of the `begin_keywords and
// `end_keywords directives are not affected by the `resetall directive.
// `begin_keywords "1364-2005" is followed by `resetall, both outside any
// design element. IEEE Std 1364-2005 does not reserve logic (22.14.5), so
// in the module kw_after_resetall logic is still an identifier, and
// logic x; would be an instantiation of a module named logic without the
// required parentheses or a declaration of a type named logic, which does
// not exist. That line is the only error: a tool whose `resetall restored
// the default keywords would read it as a legal variable declaration. The
// `end_keywords after the module completes the pair.

`begin_keywords "1364-2005"
`resetall

module kw_after_resetall;
  logic x;  // illegal: logic is not a keyword of IEEE Std 1364-2005
endmodule
`end_keywords

module test_illegal_begin_keywords_survives_resetall;
  logic y = 1'b0;
  kw_after_resetall u();
endmodule
