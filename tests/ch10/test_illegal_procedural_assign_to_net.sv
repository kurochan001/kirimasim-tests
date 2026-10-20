/*
:name: test_illegal_procedural_assign_to_net
:description: A procedural assignment cannot write a net (IEEE 1800-2023 Section 10.4)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.4 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure assigns to the net w
:expected_stderr_regex: test_illegal_procedural_assign_to_net\.sv:20:
*/
// IEEE 1800-2023 §10.4: the left-hand side of a procedural assignment is a
// variable. w is a net, which only continuous assignments and drivers can write
// (6.5).

module test_illegal_procedural_assign_to_net;
  wire w;
  initial w = 1'b1;    // illegal: w is a net
endmodule
