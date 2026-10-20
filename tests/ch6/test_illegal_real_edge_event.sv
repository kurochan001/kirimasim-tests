/*
:name: test_illegal_real_edge_event
:description: An edge event control on a real variable is not allowed (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 9.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the design waits for posedge of the real variable r
:expected_stderr_regex: test_illegal_real_edge_event\.sv:19:
*/
// IEEE 1800-2023 §6.12: posedge, negedge and edge cannot be applied to a real
// variable (9.4.2).

module test_illegal_real_edge_event;
  real r = 0.0;
  always @(posedge r) $display("edge");   // illegal: an edge of a real
  initial #1 r = 1.0;
endmodule
