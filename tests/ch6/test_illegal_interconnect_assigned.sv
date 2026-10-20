/*
:name: test_illegal_interconnect_assigned
:description: An interconnect net cannot be the target of a continuous assignment (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.8 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a continuous assignment drives the interconnect net n
:expected_stderr_regex: test_illegal_interconnect_assigned\.sv:20:
*/
// IEEE 1800-2023 §6.6.8: an interconnect net only expresses port and terminal
// connections; it cannot be used in continuous assignments or in procedural
// code.

module test_illegal_interconnect_assigned;
  interconnect n;
  assign n = 1'b1;     // illegal: interconnect in an assignment
endmodule
