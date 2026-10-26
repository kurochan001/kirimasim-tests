/*
:name: test_illegal_value_plusargs_bad_format
:description: the user string of $value$plusargs has a conversion that is not allowed (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the user string "COUNT%q" uses the conversion %q
:expected_stderr_regex: test_illegal_value_plusargs_bad_format\.sv:21:
*/
// The user string of $value$plusargs holds a plusarg prefix and a
// conversion format, and only %d, %o, %h, %x, %b, %e, %f, %g and %s are
// valid. The conversion %q here is not one of them.

module test_illegal_value_plusargs_bad_format;
  int v;
  initial begin
    $display("%0d", $value$plusargs("COUNT%q", v));   // illegal: %q
  end
endmodule
