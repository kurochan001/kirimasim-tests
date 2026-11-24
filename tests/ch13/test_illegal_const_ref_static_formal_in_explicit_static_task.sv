/*
:name: test_illegal_const_ref_static_formal_in_explicit_static_task
:description: A const ref static formal is invalid in a task with static lifetime
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a const ref static formal does not permit a static-lifetime task
:expected_stderr_regex: test_illegal_const_ref_static_formal_in_explicit_static_task\.sv:21:(?:\d+:)?[^\n]*(?i:(?=[^\n]*\b(?:ref|reference)\b)(?=[^\n]*\b(?:static|automatic)\b)(?=[^\n]*\b(?:lifetime|subroutines?|functions?|tasks?)\b)[^\n]*\b(?:illegal|forbid(?:den)?|cannot|not permitted|can only)\b)
*/
module test_illegal_const_ref_static_formal_in_explicit_static_task;
  int state = 4;

  task automatic allowed(const ref static int value);
    $display("automatic=%0d", value);
  endtask

  task static forbidden(const ref static int value); // illegal
    $display("static=%0d", value);
  endtask

  initial begin
    allowed(state);
    forbidden(state);
  end
endmodule
