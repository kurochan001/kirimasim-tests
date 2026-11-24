/*
:name: test_illegal_ref_static_formal_in_explicit_static_function
:description: A ref static formal is invalid in a function with static lifetime
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a ref static formal does not permit a static-lifetime function
:expected_stderr_regex: test_illegal_ref_static_formal_in_explicit_static_function\.sv:21:(?:\d+:)?[^\n]*(?i:(?=[^\n]*\b(?:ref|reference)\b)(?=[^\n]*\b(?:static|automatic)\b)(?=[^\n]*\b(?:lifetime|subroutines?|functions?|tasks?)\b)[^\n]*\b(?:illegal|forbid(?:den)?|cannot|not permitted|can only)\b)
*/
module test_illegal_ref_static_formal_in_explicit_static_function;
  int state = 4;

  function automatic int allowed(ref static int value);
    return value + 2;
  endfunction

  function static int forbidden(ref static int value); // illegal
    return value + 1;
  endfunction

  initial $display("sum=%0d", allowed(state) + forbidden(state));
endmodule
