/*
:name: test_illegal_udp_ansi_table_declares_two_outputs
:description: An ANSI primitive port list cannot declare a second output
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the primitive declares two output ports
:expected_stderr_regex: test_illegal_udp_ansi_table_declares_two_outputs\.sv:14:
*/
primitive two_state_outputs(output first, output second, input command);
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module test_illegal_udp_ansi_table_declares_two_outputs;
  wire first, second;
  two_state_outputs dut(first, second, 1'b0);
endmodule
