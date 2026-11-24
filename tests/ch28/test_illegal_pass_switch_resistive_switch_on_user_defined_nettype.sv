/*
:name: test_illegal_pass_switch_resistive_switch_on_user_defined_nettype
:description: A resistive pass switch cannot connect a user-defined nettype
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.8 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a resistive pass switch cannot connect a user-defined nettype
:expected_stderr_regex: test_illegal_pass_switch_resistive_switch_on_user_defined_nettype\.sv:21:(?:\d+:)?[^\n]*(?i:(?:rtran|resistive)[^\n]*(?:net|terminal)|(?:gate|switch)[^\n]*(?:cannot connect|requires)[^\n]*user.defined net type)
*/
module test_illegal_pass_switch_resistive_switch_on_user_defined_nettype;
  function automatic logic combine(input logic drivers[]);
    combine = 0;
    foreach (drivers[i]) combine |= drivers[i];
  endfunction
  nettype logic first_type with combine;
  first_type left, right;
  rtran bad_switch(left, right); // illegal
endmodule
