/*
:name: test_illegal_udp_edge_descriptor_contains_high_impedance
:description: A sequential primitive edge descriptor may use an unknown digit but may not use high impedance
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.5 29.6 A.5.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the transition descriptor in the second primitive contains z
:expected_stderr_regex: test_illegal_udp_edge_descriptor_contains_high_impedance\.sv:28:(?:\d+:)?[^\n]*(?i:(?:udp|table|descriptor|syntax|unexpected|expected))
*/
primitive edge_control(q, data);
  output q;
  reg q;
  input data;
  table
    (0x) : ? : 1;
  endtable
endprimitive

primitive edge_forbidden(q, data);
  output q;
  reg q;
  input data;
  table
    (0z) : ? : 1;
  endtable
endprimitive

module test_illegal_udp_edge_descriptor_contains_high_impedance;
  logic data;
  wire good, bad;
  edge_control lawful(good, data);
  edge_forbidden unlawful(bad, data);
endmodule
