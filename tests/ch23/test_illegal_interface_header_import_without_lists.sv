/*
:name: test_illegal_interface_header_import_without_lists
:description: A package import in an ANSI interface header has to be followed by a parameter port list, a list of port declarations or both, so an interface header with only the import is an error (IEEE 1800-2023 Section 23.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.1 23.2.2.2 25.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the header of the interface header_import_ifc has a package import declaration that is followed by neither a parameter port list nor a list of port declarations
:expected_stderr_regex: test_illegal_interface_header_import_without_lists\.sv:(26|27|28):
*/
// IEEE 1800-2023 §23.2.1 and §23.2.2.2 (footnote 1 of Syntax 23-1 and
// 23-4): a package_import_declaration in an interface_ansi_header shall be
// followed by a parameter_port_list, a list_of_port_declarations or both.
// The interface below has only the import before the semicolon that ends
// its header (25.3 gives the interface header); a tool can report the
// error on any line of the header.
// The design is accepted by Icarus Verilog 13.0 and Verilator 5.052.

package header_import_ifc_pkg;
  localparam int W = 4;
endpackage

interface header_import_ifc  // or here
  import header_import_ifc_pkg::*;  // or here
  ;  // illegal: neither list follows the import
  logic [W-1:0] v;
endinterface

module test_illegal_interface_header_import_without_lists;
  header_import_ifc i();
endmodule
