/*
:name: test_illegal_module_header_import_without_lists
:description: A package import in an ANSI module header has to be followed by a parameter port list, a list of port declarations or both, so a header with only the import is an error (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.1 23.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the header of the module has a package import declaration that is followed by neither a parameter port list nor a list of port declarations
:expected_stderr_regex: test_illegal_module_header_import_without_lists\.sv:(33|34|35):
*/
// IEEE 1800-2023 §23.2.1 and §23.2.2.2 (footnote 1 of Syntax 23-1 and
// 23-4): a package_import_declaration in a module_ansi_header shall be
// followed by a parameter_port_list, a list_of_port_declarations or both.
// The grammar of the header alone would let both be left out, which is the
// form below: the import is followed directly by the semicolon that ends
// the header. A tool can report the error on any line of the header. The
// module header_import_ok shows the legal form with an empty port list.
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052.

package header_import_module_pkg;
  localparam int W = 4;
endpackage

module header_import_ok
  import header_import_module_pkg::*;
  ();
  logic [W-1:0] v = '0;
endmodule

module test_illegal_module_header_import_without_lists  // or here
  import header_import_module_pkg::*;  // or here
  ;  // illegal: neither list follows the import
  logic [W-1:0] v = '0;
endmodule
