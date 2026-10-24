/*
:name: test_illegal_line_directive_trailing_comment
:description: Comments are not allowed on the same line as a `line directive, so a `line followed by a line comment is an error (IEEE 1800-2023 Section 22.12)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a line comment follows the first `line directive on the same line
:expected_stderr_regex: (test_illegal_line_directive_trailing_comment\.sv:22:|line_comment_target\.sv:)
*/
// IEEE 1800-2023 §22.12: only white space may appear on the same line as a
// `line directive, and comments are not allowed on that line, although
// other directives, such as `include, allow them. The first `line below is
// followed by a line comment, which is the only error. A tool can report it
// at its line in this file or at the location that the directive names.
// The second `line, after the module, is alone on its line and legal.
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052.

`line 10 "line_comment_target.sv" 0 // illegal: a comment on the line
module test_illegal_line_directive_trailing_comment;
  logic a = 1'b0;
endmodule
`line 40 "line_comment_alone.sv" 0
