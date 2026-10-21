/*
:name: test_illegal_udp_instance_three_delays
:description: An instance of a UDP can have at most two delays (IEEE 1800-2023 Section 29.8)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.8 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP instance gives three delays
:expected_stderr_regex: test_illegal_udp_instance_three_delays\.sv:31:
*/
// IEEE 1800-2023 §29.8: only two delays, rise and fall, may be specified for a
// UDP instance, because the output of a UDP cannot be z.
// The error that Verilator 5.052 reports on that line does not count: it reads
// the delays as parameter values and reports a missing parameter.

primitive test_illegal_udp_instance_three_delays_p(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module test_illegal_udp_instance_three_delays;
  logic a = 0;
  wire y;
  test_illegal_udp_instance_three_delays_p #(1, 2, 3) u(y, a);   // illegal: three delays
endmodule
