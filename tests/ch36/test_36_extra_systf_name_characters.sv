/*
:name: test_36_extra_systf_name_characters
:description: After the initial $, a system task/function name has only letters, digits, underscores and dollar signs, so a name with a hyphen is rejected (IEEE 1800-2023 Sections 36.3 and 5.6.3)
:tags: ch36
:type: elaboration
:lrm: 1800-2023 36.3 5.6.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the design writes the system task name $vt-task, whose hyphen is not one of the characters that may follow the initial $, so the name ends at $vt and the rest is not a statement
:expected_stderr_regex: test_36_extra_systf_name_characters\.sv:24:
*/
// IEEE 1800-2023 §36.3, §5.6.3: after the initial $, the characters of a
// system task/function name are the letters, the digits, the underscore and
// the dollar sign. A hyphen is therefore not part of such a name: in $vt-task
// the name is the system task $vt, followed by a minus sign and whatever
// comes next. The design below writes a hyphen in the middle of the name it
// means to call, so the text is not a call of one system task and the design
// is illegal; the marked line is the one with the hyphen.

module test_36_extra_systf_name_characters;
  initial begin
    $vt-task;   // illegal: a hyphen is not a name character after $
  end
endmodule
