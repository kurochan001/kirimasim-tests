/*
:name: test_illegal_udp_table_entry_without_semicolon
:description: Each entry of a UDP table ends with a semicolon (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an entry of the UDP table has no semicolon
:expected_stderr_regex: test_illegal_udp_table_entry_without_semicolon\.sv:(22|23):
*/
// IEEE 1800-2023 §29.3.4: a UDP table begins with table and ends with
// endtable, and each of its entries ends with a semicolon. The first
// entry here has none; a tool can report it there or at the next entry.

primitive test_illegal_udp_table_entry_without_semicolon_p(y, a);
  output y;
  input a;
  table
    0 : 1   // illegal: no semicolon
    1 : 0;   // error here
  endtable
endprimitive

module test_illegal_udp_table_entry_without_semicolon;
  logic a = 0;
  wire y;
  test_illegal_udp_table_entry_without_semicolon_p u(y, a);
endmodule
