/*
:name: test_illegal_mixed_ansi_and_nonansi_ports
:description: A module is declared either entirely with the non-ANSI list of ports or entirely with the ANSI list of port declarations, so a port list that starts with a non-ANSI port and continues with ANSI declarations is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port list of mixed_header starts with the non-ANSI port a and continues with the ANSI port declarations of b and y
:expected_stderr_regex: test_illegal_mixed_ansi_and_nonansi_ports\.sv:21:
*/
// IEEE 1800-2023 §23.2.2.2: each module shall be declared either entirely
// with the list_of_ports syntax of 23.2.2.1 or entirely with the
// list_of_port_declarations syntax. The header of mixed_header names a
// as a non-ANSI port, declared in the body, and declares b and y in the
// ANSI style.
// The design is accepted by Verilator 5.052.

module mixed_header(a, input logic b, output logic y);  // illegal: mixed styles
  input a;
  assign y = a & b;
endmodule

module test_illegal_mixed_ansi_and_nonansi_ports;
  logic a = 1'b1, b = 1'b1;
  wire y;
  mixed_header u(a, b, y);
endmodule
