/*
:name: test_22_extra_directive_nesting
:description: A compiler directive shall not stand in the middle of another directive, so an `include whose file-name position holds a second `include is an error (IEEE 1800-2023 Section 22.2)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second `include is a directive in the middle of the first `include, which needs a file name there
:expected_stderr_regex: test_22_extra_directive_nesting\.sv:21:
*/
// IEEE 1800-2023 §22.2: a directive may appear in a conditional compilation
// block of text or in macro text, and there it is processed when the text is
// used; a macro usage is not a directive. Otherwise a compiler directive shall
// not appear in the middle of another directive. The `include below needs a
// quoted or angle-bracket file name, and the second `include is a directive,
// not a file name, so the design is rejected at that directive.

`include `include
module test_22_extra_directive_nesting;
endmodule
