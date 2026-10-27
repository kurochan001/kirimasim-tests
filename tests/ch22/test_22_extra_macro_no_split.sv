/*
:name: test_22_extra_macro_no_split
:description: The text of a macro shall not be split across a string literal, so a macro whose text ends inside a string is an error (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: elaboration
:lrm: 1800-2023 22.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the macro text ends in the middle of a string literal and the text after the use would have to finish it
:expected_stderr_regex: test_22_extra_macro_no_split\.sv:(?:24|25):
*/
// IEEE 1800-2023 §22.5.1: the text specified for macro text shall not be
// split across comments, numbers, string literals, identifiers, keywords or
// operators. The definition below holds an opening double quote that is never
// closed inside the macro text; the use is followed by the rest of the
// literal. That is the illegal split of the standard's own example. Verilator
// 5.052 rejects the unterminated string in the definition. Icarus Verilog
// 13.0 joins the macro text with the following line and accepts the design,
// so the expected output of this test is not from Icarus and the test is
// reported as a known difference there.

`define HALF "start of string
module test_22_extra_macro_no_split;
  initial $display(`HALF end of string");
endmodule
