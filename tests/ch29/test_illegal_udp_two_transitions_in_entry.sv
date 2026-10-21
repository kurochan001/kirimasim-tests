/*
:name: test_illegal_udp_two_transitions_in_entry
:description: A table entry of a sequential UDP can have a transition on at most one input (IEEE 1800-2023 Section 29.6)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.6 29.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a table entry gives transitions for two inputs
:expected_stderr_regex: test_illegal_udp_two_transitions_in_entry\.sv:25:
*/
// IEEE 1800-2023 §29.6 and §29.3.4: each entry of a UDP table can specify a
// transition on at most one input.
// Icarus Verilog 13.0 accepts the design (docs/simulator-differences.md).

primitive test_illegal_udp_two_transitions_in_entry_p(q, clk, d);
  output q;
  reg q;
  input clk, d;
  table
    (01) 0 : ? : 0;
    (01) 1 : ? : 1;
    r f : ? : 0;   // illegal: transitions on two inputs
    (10) ? : ? : -;
    ? * : ? : -;
  endtable
endprimitive

module test_illegal_udp_two_transitions_in_entry;
  logic clk = 0, d = 0;
  wire q;
  test_illegal_udp_two_transitions_in_entry_p u(q, clk, d);
endmodule
