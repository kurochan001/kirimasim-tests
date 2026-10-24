/*
:name: test_illegal_line_directive_sets_following_location
:description: The compiler keeps the current file name and line number, and a `line directive, which can stand anywhere, sets them for the following line, so an error two lines after `line 500 "orig/line_renamed.sv" 0 inside a module is reported at line 501 of orig/line_renamed.sv (IEEE 1800-2023 Section 22.12)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable c that the initial procedure assigns is not declared
:expected_stderr_regex: orig/line_renamed\.sv:501:
*/
// IEEE 1800-2023 §22.12: the compiler shall maintain the current line
// number and file name, and the `line directive shall set the line number
// and file name of the following line to those it gives; it can be
// specified anywhere in the source, and the line number then increases with
// each line read. The `line below stands between two items of the module
// and names the relative path orig/line_renamed.sv. The line after it is
// therefore line 500 of that file, and the next one, which assigns the
// undeclared variable c, is line 501. That assignment is the only error,
// and a tool reports it at orig/line_renamed.sv line 501; a tool that
// ignored the `line directive would report it at the line of this file.

module test_illegal_line_directive_sets_following_location;
  logic a = 1'b0;
`line 500 "orig/line_renamed.sv" 0
  logic b = 1'b1;
  initial c = 1'b1;  // illegal: c is not declared
endmodule
