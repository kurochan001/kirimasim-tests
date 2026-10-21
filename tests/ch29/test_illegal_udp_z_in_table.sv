/*
:name: test_illegal_udp_z_in_table
:description: The value z cannot appear in a UDP table entry (IEEE 1800-2023 Section 29.3.5)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.5 29.3.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a table entry of the UDP uses z
:expected_stderr_regex: test_illegal_udp_z_in_table\.sv:23:
*/
// IEEE 1800-2023 §29.3.5: z in a table entry is not supported and is
// illegal; a z on an input is matched as x instead.

primitive test_illegal_udp_z_in_table_p(y, a);
  output y;
  input a;
  table
    0 : 0;
    1 : 1;
    z : 0;   // illegal: z in a table entry
  endtable
endprimitive

module test_illegal_udp_z_in_table;
  logic a = 0;
  wire y;
  test_illegal_udp_z_in_table_p u(y, a);
endmodule
