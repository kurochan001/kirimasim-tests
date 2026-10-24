/*
:name: test_illegal_include_line_trailing_code
:description: Only white space or a comment may appear on the same line as an `include directive, so a declaration after the file name on that line is an error (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_line_trailing_code.svh
:should_fail_because: a localparam declaration follows the `include directive on the same line
:expected_stderr_regex: test_illegal_include_line_trailing_code\.sv:25:
*/
// IEEE 1800-2023 §22.4: only white space or a comment may share the line
// of an `include directive. The first `include is followed by a comment
// and is legal; the second one, of another file, is followed by a
// declaration that would be legal on a line of its own, and that is the
// only error. The file that :files: names declares one localparam.
// The design is accepted by Verilator 5.052.

module test_illegal_include_line_trailing_code;
  `include "include_line_trailing_code.svh" // a comment is allowed here
  localparam int B = INCLUDE_LINE_TRAILING_A + 1;
  `include "include_line_trailing_code.svh" localparam int C = 2;  // illegal
endmodule
