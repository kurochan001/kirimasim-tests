/*
:name: test_illegal_udp_state_table_produces_high_impedance
:description: A sequential primitive cannot assign high impedance to its output state
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a sequential table entry assigns high impedance to the output state
:expected_stderr_regex: test_illegal_udp_state_table_produces_high_impedance\.sv:21:(?:\d+:)?[^\n]*(?i:UdpInvalidSymbol|invalid symbol|rule[^\n]*state[^\n]*['"]z['"])
*/
primitive high_impedance_state(state, command);
  output state;
  reg state;
  input command;
  initial state = 1'b1;
  table
    0 : ? : 0;
    1 : ? : z;
  endtable
endprimitive

module test_illegal_udp_state_table_produces_high_impedance(input logic command, output wire state);
  high_impedance_state dut(state, command);
endmodule
