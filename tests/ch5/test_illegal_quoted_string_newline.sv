/*
:name: test_illegal_quoted_string_newline
:description: A quoted string cannot contain a newline that is not escaped (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.9
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a quoted string, not a triple-quoted one, goes on to the next line
:expected_stderr_regex: test_illegal_quoted_string_newline\.sv:(20|21):
*/
// IEEE 1800-2023 §5.9: a quoted string is in one pair of double quotes, and its
// characters cannot include a newline unless it is escaped; only a
// triple-quoted string holds one. A tool can report the line where the string
// starts or the next one.

module test_illegal_quoted_string_newline;
  initial $display("first part   // illegal: the string goes on to the next line
second part");   // error here
endmodule
