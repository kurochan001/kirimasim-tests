/*
:name: test_23_extra_generic_interface_nonansi
:description: A generic interface port can only be declared with the ANSI list of port declarations, so a generic interface port with a modport in a non-ANSI module header is an error (IEEE 1800-2023 Section 23.2.2.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.2 23.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module header of gi uses the non-ANSI style while its body tries to declare the generic interface port i with a modport
:expected_stderr_regex: test_23_extra_generic_interface_nonansi\.sv:26:
*/
// IEEE 1800-2023 §23.2.2.2: generic interface ports cannot be declared with
// the non-ANSI style list_of_ports syntax of §23.2.2.1; they can only be
// declared with the ANSI style list_of_port_declarations syntax, where the
// keyword interface stands in the port list, optionally followed by a
// modport. The header of gi is a non-ANSI list and its body writes the
// generic interface form interface .mp i, which has no non-ANSI port
// declaration in Syntax 23-3. The design is therefore illegal.
// Icarus Verilog 13.0 and Verilator 5.052 reject the line as a syntax error,
// which is also the only way to write this illegal combination; see the note
// below.

module gi(i);
  interface .mp i;
endmodule

module test_23_extra_generic_interface_nonansi;
  gi u();
endmodule
