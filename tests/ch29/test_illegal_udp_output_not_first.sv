/*
:name: test_illegal_udp_output_not_first
:description: The output port of a UDP is the first port in its port list (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output is not the first port of the UDP
:expected_stderr_regex: test_illegal_udp_output_not_first\.sv:(18|19):
*/
// IEEE 1800-2023 §29.3.1: the output port shall be the first port in the
// port list of a UDP. A tool can report the header or the declaration of the
// first port.

primitive test_illegal_udp_output_not_first_p(a, y);   // illegal: output listed second
  input a;   // error here
  output y;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module test_illegal_udp_output_not_first;
  logic a = 0;
  wire y;
  test_illegal_udp_output_not_first_p u(a, y);
endmodule
