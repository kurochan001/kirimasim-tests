/*
:name: test_illegal_udp_initial_block
:description: The initial statement of a UDP holds one procedural assignment, not a block (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.7 29.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial statement of the UDP is a block with two assignments
:expected_stderr_regex: test_illegal_udp_initial_block\.sv:24:
*/
// IEEE 1800-2023 §29.7, Table 29-2: the initial statement of a UDP is
// limited to one procedural assignment, while one in a module can be any
// procedural statement or a block of several (also 29.3.3). This UDP has
// a begin-end block with two assignments.
// The design is accepted by Verilator 5.052.

primitive test_illegal_udp_initial_block_p(q, en, d);
  output q;
  reg q;
  input en, d;
  initial begin q = 1'b0; q = 1'b1; end   // illegal: a block in a UDP initial statement
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_illegal_udp_initial_block;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_initial_block_p u(q, en, d);
endmodule
