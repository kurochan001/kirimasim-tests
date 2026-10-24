/*
:name: test_illegal_program_header_import_without_port_list
:description: A package import in an ANSI program header has to be followed by a parameter port list or a port list (IEEE 1800-2023 Section 26.4)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.4 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the header of phi_bad imports phi_pkg and then ends without a parameter port list or a port list
:expected_stderr_regex: test_illegal_program_header_import_without_port_list\.sv:37:
*/
// IEEE 1800-2023 §26.4: a package import declaration in a
// program_ansi_header shall be followed by a parameter_port_list, a
// list_of_port_declarations or both (footnote 1 of Syntax 26-3, repeated in
// 25.3). The headers of phi_ports, phi_params and phi_empty follow the
// import with a port list, a parameter port list and an empty port list,
// which are legal. The header of phi_bad ends right after its import.
// Oracle checks: Icarus Verilog 13.0 accepts the design; the 5.052 release
// of Verilator does not parse a package import in a program header and reports
// syntax errors on the legal headers.

package phi_pkg;
  typedef logic [3:0] nib_t;
endpackage

program phi_ports import phi_pkg::*; (input nib_t a);
endprogram

program phi_params import phi_pkg::*; #(parameter nib_t P = 4'd1);
endprogram

program phi_empty import phi_pkg::*; ();
endprogram

program phi_bad import phi_pkg::*; ;   // illegal: no list after the import
endprogram

module test_illegal_program_header_import_without_port_list;
endmodule
