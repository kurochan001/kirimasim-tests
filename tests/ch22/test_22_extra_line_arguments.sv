/*
:name: test_22_extra_line_arguments
:description: The level argument of `line shall be 0, 1 or 2, so a level of 3 is an error (IEEE 1800-2023 Section 22.12)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.12
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the level of the `line directive is 3, which is not one of the three allowed values
:expected_stderr_regex: test_22_extra_line_arguments\.sv:22:
*/
// IEEE 1800-2023 §22.12: all three parameters of the `line directive are
// required. The number is a positive integer that gives the new line number of
// the following text line, the file name is a string literal, and the level is
// 0, 1 or 2. The directive below has a valid line number and file name but a
// level of 3, so the design is rejected at the directive. A line number of 0
// is not positive and is also illegal; Verilator 5.052 does not check that
// one, so it is not the case this test uses.

`line 20 "line_arguments_target.sv" 3
module test_22_extra_line_arguments;
  initial $display("unreachable");
endmodule
