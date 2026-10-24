/*
:name: test_illegal_udp_hyphen_combinational
:description: The UDP symbol - is allowed only in the output field of a sequential UDP (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a combinational UDP has - as an output
:expected_stderr_regex: test_illegal_udp_hyphen_combinational\.sv:25:
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: - (no change) is permitted only in
// the output field of a sequential UDP. This UDP is combinational, without
// a reg and a current state field, and its second entry has - as output.
// Icarus Verilog 13.0 stops on an internal assertion instead of reporting
// the error, and Verilator 5.052 accepts the design.

primitive test_illegal_udp_hyphen_combinational_p(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : -;   // illegal: - in a combinational UDP
  endtable
endprimitive

module test_illegal_udp_hyphen_combinational;
  logic a = 0;
  wire y;
  test_illegal_udp_hyphen_combinational_p u(y, a);
endmodule
