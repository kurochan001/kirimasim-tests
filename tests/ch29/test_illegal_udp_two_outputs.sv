/*
:name: test_illegal_udp_two_outputs
:description: A UDP must have exactly one output port (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.1 29.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP declares two outputs
:expected_stderr_regex: test_illegal_udp_two_outputs\.sv:(19|21):
*/
// IEEE 1800-2023 §29.3.1: a UDP has exactly one output port, the first in
// its port list (29.3.2: the output declaration names one output port).
// This UDP declares a second port as an output too. A tool can report the
// header or the second output declaration.

primitive test_illegal_udp_two_outputs_p(y, z, a);   // error here
  output y;
  output z;   // illegal: a second output
  input a;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module test_illegal_udp_two_outputs;
  logic a = 0;
  wire y, z;
  test_illegal_udp_two_outputs_p u(y, z, a);
endmodule
