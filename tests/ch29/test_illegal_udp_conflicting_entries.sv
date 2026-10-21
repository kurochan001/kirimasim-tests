/*
:name: test_illegal_udp_conflicting_entries
:description: Two entries of a UDP table cannot give different outputs for the same input combination (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4 29.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two table entries give different outputs for the same inputs
:expected_stderr_regex: test_illegal_udp_conflicting_entries\.sv:26:
*/
// IEEE 1800-2023 §29.3.4: it shall be illegal for the same combination of
// inputs, edges included, to specify different output values.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design
// (docs/simulator-differences.md).

primitive test_illegal_udp_conflicting_entries_p(y, a, b);
  output y;
  input a, b;
  table
    0 0 : 0;
    0 1 : 1;
    1 ? : 1;
    1 0 : 0;   // illegal: 1 0 also matches the entry before
  endtable
endprimitive

module test_illegal_udp_conflicting_entries;
  logic a = 0, b = 0;
  wire y;
  test_illegal_udp_conflicting_entries_p u(y, a, b);
endmodule
