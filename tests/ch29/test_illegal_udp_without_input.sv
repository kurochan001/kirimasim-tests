/*
:name: test_illegal_udp_without_input
:description: A UDP must have at least one input port (IEEE 1800-2023 Section 29.3.1)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.1 29.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP has an output and no input
:expected_stderr_regex: test_illegal_udp_without_input\.sv:(19|22):
*/
// IEEE 1800-2023 §29.3.1: a UDP has exactly one output and one or more
// inputs; its port list is the output followed by at least one input
// (Syntax 29-1, 29.3). This UDP lists only its output. A tool can report
// the header or the table entry, which has one input field but no input.

primitive test_illegal_udp_without_input_p(y);   // illegal: no input port
  output y;
  table
    1 : 1;   // error here
  endtable
endprimitive

module test_illegal_udp_without_input;
  wire y;
  test_illegal_udp_without_input_p u(y);
endmodule
