/*
:name: test_illegal_named_connection_port_bit_select
:description: A named port connection names the port as declared, so it cannot name a bit-select of the port (IEEE 1800-2023 Section 23.3.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the named connection of u names a bit-select a[0] of the port a instead of the port
:expected_stderr_regex: test_illegal_named_connection_port_bit_select\.sv:24:
*/
// IEEE 1800-2023 §23.3.2.2: the port name of a named port connection is
// the name in the module declaration; it cannot be a bit-select, a
// part-select or a concatenation of ports. u connects .a[0], a bit-select
// of the port a; .a(p) would be legal.

module named_connection_bit_select_m(input logic [1:0] a);
endmodule

module test_illegal_named_connection_port_bit_select;
  logic p = 1'b0;
  named_connection_bit_select_m u(.a[0](p));   // illegal
endmodule
