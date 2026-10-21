/*
:name: test_illegal_udp_inout_port
:description: A UDP cannot have an inout port (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.1 29.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a port of the UDP is declared inout
:expected_stderr_regex: test_illegal_udp_inout_port\.sv:20:
*/
// IEEE 1800-2023 §29.3.1: a UDP has one output and one or more inputs;
// bidirectional inout ports are not permitted.

primitive test_illegal_udp_inout_port_p(y, a, b);
  output y;
  input a;
  inout b;   // illegal: inout port of a UDP
  table
    0 ? : 0;
    1 ? : 1;
  endtable
endprimitive

module test_illegal_udp_inout_port;
  logic a = 0;
  wire b, y;
  test_illegal_udp_inout_port_p u(y, a, b);
endmodule
