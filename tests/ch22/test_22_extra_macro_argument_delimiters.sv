/*
:name: test_22_extra_macro_argument_delimiters
:description: An actual argument of a macro use shall not contain a comma outside matched pairs of parentheses, so a comma held in an unclosed parenthesis is not an argument separator and the use is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the comma in the first actual argument is inside a left parenthesis that is not closed, so the use has one actual for two formals
:expected_stderr_regex: test_22_extra_macro_argument_delimiters\.sv:25:
*/
// IEEE 1800-2023 §22.5.1: actual arguments and defaults shall not contain
// comma or right parenthesis characters outside matched pairs of parentheses,
// square brackets, braces, double or triple quotes, or an escaped identifier.
// The first actual below is `(1 + 2, 3`: the comma is inside a left
// parenthesis that has no matching right parenthesis inside the actual, so it
// does not separate two actual arguments. The parenthesis that follows 3
// closes the actual and the parenthesis after it closes the use, leaving one
// actual argument for the two formal arguments a and b.

`define ADD(a,b) ((a) + (b))
module test_22_extra_macro_argument_delimiters;
  initial $display("%0d", `ADD((1 + 2, 3));
endmodule
