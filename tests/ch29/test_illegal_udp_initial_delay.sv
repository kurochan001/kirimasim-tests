/*
:name: test_illegal_udp_initial_delay
:description: The initial statement of a sequential UDP cannot have a delay (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.7 29.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial statement of the UDP has a delay
:expected_stderr_regex: test_illegal_udp_initial_delay\.sv:22:
*/
// IEEE 1800-2023 §29.7: delays are not permitted in a UDP initial statement.
// §29.3.3: the statement assigns a single-bit literal value to the output.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

primitive test_illegal_udp_initial_delay_p(q, en, d);
  output q;
  reg q;
  input en, d;
  initial #1 q = 1;   // illegal: delay in a UDP initial statement
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_illegal_udp_initial_delay;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_initial_delay_p u(q, en, d);
endmodule
