/*
:name: test_illegal_udp_vector_port
:description: The ports of a UDP are scalar; a vector input is not allowed (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.1 29.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an input port of the UDP is declared as a vector
:expected_stderr_regex: test_illegal_udp_vector_port\.sv:20:
*/
// IEEE 1800-2023 §29.3.1: all ports of a UDP shall be scalar; vector ports
// are not permitted.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

primitive test_illegal_udp_vector_port_p(y, a);
  output y;
  input [1:0] a;   // illegal: vector port of a UDP
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module test_illegal_udp_vector_port;
  logic [1:0] a = 0;
  wire y;
  test_illegal_udp_vector_port_p u(y, a);
endmodule
