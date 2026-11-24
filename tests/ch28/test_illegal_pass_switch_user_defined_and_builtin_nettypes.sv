/*
:name: test_illegal_pass_switch_user_defined_and_builtin_nettypes
:description: A bidirectional switch cannot connect a user-defined nettype to a built-in nettype
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a bidirectional switch cannot connect a user-defined nettype to a built-in nettype
:expected_stderr_regex: test_illegal_pass_switch_user_defined_and_builtin_nettypes\.sv:22:(?:\d+:)?[^\n]*(?i:(?:different|incompatible|mismatch|mix|built.in|resistive|rtran)[^\n]*(?:nettype|net type|terminal|net)|(?:nettype|net type|terminal|net)[^\n]*(?:different|incompatible|mismatch|mix|built.in|resistive|rtran))
*/
module test_illegal_pass_switch_user_defined_and_builtin_nettypes;
  function automatic logic combine(input logic drivers[]);
    combine = 0;
    foreach (drivers[i]) combine |= drivers[i];
  endfunction
  nettype logic first_type with combine;
  first_type left;
  wire right;
  tranif1 bad_switch(left, right, 1'b0); // illegal
endmodule
