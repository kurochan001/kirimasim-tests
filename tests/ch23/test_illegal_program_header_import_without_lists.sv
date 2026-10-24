/*
:name: test_illegal_program_header_import_without_lists
:description: A package import in an ANSI program header has to be followed by a parameter port list, a list of port declarations or both, so a program header with only the import is an error (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.1 23.2.2.2 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the header of the program header_import_prog has a package import declaration that is followed by neither a parameter port list nor a list of port declarations
:expected_stderr_regex: test_illegal_program_header_import_without_lists\.sv:(29|30|31):
*/
// IEEE 1800-2023 §23.2.1 and §23.2.2.2 (footnote 1 of Syntax 23-1 and
// 23-4): a package_import_declaration in a program_ansi_header shall be
// followed by a parameter_port_list, a list_of_port_declarations or both.
// The program below has only the import before the semicolon that ends its
// header (24.3 gives the program header); a tool can report the error on
// any line of the header.
// The design is accepted by Icarus Verilog 13.0. Verilator 5.052 rejects
// it on the line of the import, but it rejects a package import in a
// program header also when a port list follows, which is legal, so that
// error does not come from this rule.

package header_import_prog_pkg;
  localparam int W = 4;
endpackage

program header_import_prog  // or here
  import header_import_prog_pkg::*;  // or here
  ;  // illegal: neither list follows the import
  logic [W-1:0] v;
endprogram

module test_illegal_program_header_import_without_lists;
  header_import_prog p();
endmodule
