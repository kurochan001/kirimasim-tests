/*
:name: test_illegal_pass_switch_distinct_user_nettypes
:description: Two independently declared user-defined nettypes are incompatible even with the same base and resolver
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two independently declared user-defined nettypes are incompatible even with the same base and resolver
:expected_stderr_regex: test_illegal_pass_switch_distinct_user_nettypes\.sv:23:(?:\d+:)?[^\n]*(?i:(?:different|incompatible|mismatch|mix|built.in|resistive|rtran)[^\n]*(?:nettype|net type|terminal|net)|(?:nettype|net type|terminal|net)[^\n]*(?:different|incompatible|mismatch|mix|built.in|resistive|rtran))
*/
module test_illegal_pass_switch_distinct_user_nettypes;
  function automatic logic combine(input logic drivers[]);
    combine = 0;
    foreach (drivers[i]) combine |= drivers[i];
  endfunction
  nettype logic first_type with combine;
  nettype logic second_type with combine;
  first_type left;
  second_type right;
  tranif0 bad_switch(left, right, 1'b1); // illegal
endmodule
