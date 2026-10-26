/*
:name: test_illegal_udp_table_without_endtable
:description: A UDP table must end with endtable (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP table has no endtable
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented))[^\n]*test_illegal_udp_table_without_endtable\.sv:(?:24:|23:(?:\d+:)?[^\n]*(?i:expected[^\n]*endtable))
*/
// IEEE 1800-2023 §29.3.4: a UDP table begins with the keyword table and
// ends with the keyword endtable. Here endprimitive follows the last
// entry; a tool can report it there.

primitive test_illegal_udp_table_without_endtable_p(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : 0;
endprimitive   // illegal: no endtable before it

module test_illegal_udp_table_without_endtable;
  logic a = 0;
  wire y;
  test_illegal_udp_table_without_endtable_p u(y, a);
endmodule
