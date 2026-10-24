/*
:name: test_illegal_system_name_space_after_dollar
:description: White space between the dollar sign and the name of a system task is rejected (IEEE 1800-2023 Section 5.6.3)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.6.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the $ of the system task call is followed by white space, which a system_tf_identifier does not allow
:expected_stderr_regex: test_illegal_system_name_space_after_dollar\.sv:22:
*/
// IEEE 1800-2023 §5.6.3 (Syntax 5-1 and its footnote): the $ that starts a
// system task or function name shall not be followed by white space. The
// first call is legal; the call on the marked line separates $ from
// display with a space and is an error.

module test_illegal_system_name_space_after_dollar;
  initial begin
    $display("first");
    $ display("second");   // illegal: white space after $
  end
endmodule
