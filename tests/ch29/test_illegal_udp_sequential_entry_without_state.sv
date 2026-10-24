/*
:name: test_illegal_udp_sequential_entry_without_state
:description: Every entry of a sequential UDP table needs the current state field between the inputs and the next state (IEEE 1800-2023 Section 29.3.4)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an entry of a sequential UDP table has no current state field
:expected_stderr_regex: test_illegal_udp_sequential_entry_without_state\.sv:(22|23|27):
*/
// IEEE 1800-2023 §29.3.4: a sequential UDP has an additional field for the
// current state between the input fields and the output field, delimited
// by colons. The output of this UDP is reg and its other entries have the
// field, but one entry has only the inputs and the output. A tool can
// report the entry, or the output and its reg declaration, which do not
// fit a table with such an entry.

primitive test_illegal_udp_sequential_entry_without_state_p(q, en, d);
  output q;   // error here
  reg q;   // error here
  input en, d;
  table
    1 0 : ? : 0;
    1 1 : 1;   // illegal: no current state field
    0 ? : ? : -;
  endtable
endprimitive

module test_illegal_udp_sequential_entry_without_state;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_sequential_entry_without_state_p u(q, en, d);
endmodule
