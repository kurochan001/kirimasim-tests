/*
:name: test_illegal_unnamed_bidirectional_switch_array
:description: A scalar switch can be unnamed and a switch array requires an instance identifier
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the array of bidirectional pass switches has a range and no instance identifier
:expected_stderr_regex: test_illegal_unnamed_bidirectional_switch_array\.sv:20:(?:\d+:)?[^\n]*(?i:(?:syntax error|expected[^\n]*(?:identifier|name)|missing[^\n]*(?:identifier|name)|unnamed|expected[ _]*hierarchical[ _]*instantiation))
*/
module test_illegal_unnamed_bidirectional_switch_array;
  wire single_a, single_b;
  wire [1:0] array_a, named_b, extra_b;

  tran (single_a, single_b);
  tran named[1:0] (array_a, named_b);
  tran [1:0] (array_a, extra_b); // illegal
endmodule
