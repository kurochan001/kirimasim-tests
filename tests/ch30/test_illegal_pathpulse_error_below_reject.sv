/*
:name: test_illegal_pathpulse_error_below_reject
:description: a PATHPULSE error limit is smaller than its reject limit (IEEE 1800-2023 Section 30.7)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: PATHPULSE$a$b gives the error limit 2, below the reject limit 5
:expected_stderr_regex: test_illegal_pathpulse_error_below_reject\.sv:21:
*/
// The reject and error limits of a path partition the pulses, and the
// error limit shall be at least the reject limit. This path gives the
// reject limit 5 and the error limit 2.

module t(input logic a, output logic b);
  specify
    (a => b) = 6;
    specparam PATHPULSE$a$b = (5, 2);   // illegal: error below reject
  endspecify
endmodule
