/*
:name: test_illegal_checker_port_list_has_two_wildcards
:description: A checker port list can have only one wildcard token pair
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.3 A.4.1.4 A.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second wildcard repeats the wildcard token pair in a single checker connection list
:expected_stderr_regex: test_illegal_checker_port_list_has_two_wildcards\.sv:20:(?:\d+:)?[^\n]*(?i:(?:multiple|duplicate|more than one|only one|repeat)[^\n]*(?:wildcard|\.\*)|(?:wildcard|\.\*)[^\n]*(?:multiple|duplicate|more than one|only one|repeat))
*/
checker single_wildcard_checker(input bit gate);
endchecker

module test_illegal_checker_port_list_has_two_wildcards;
  bit gate = 0;
  single_wildcard_checker allowed(.*);
  single_wildcard_checker rejected(.*, .*); // illegal
endmodule
