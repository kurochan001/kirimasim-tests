/*
:name: test_illegal_udp_initial_assigns_input
:description: The initial statement of a UDP must assign the reg of its output port (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.7 29.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial statement of the UDP assigns an input
:expected_stderr_regex: test_illegal_udp_initial_assigns_input\.sv:23:
*/
// IEEE 1800-2023 §29.7, Table 29-2: the assignment in the initial statement
// of a UDP assigns the reg whose name is that of the output port (also
// 29.3.3). This UDP assigns its input d instead.
// Icarus Verilog 13.0 accepts the design.

primitive test_illegal_udp_initial_assigns_input_p(q, en, d);
  output q;
  reg q;
  input en, d;
  initial d = 1'b1;   // illegal: an input as target
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_illegal_udp_initial_assigns_input;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_initial_assigns_input_p u(q, en, d);
endmodule
