/*
:name: test_illegal_interface_header_import_without_port_list
:description: A package import in an ANSI interface header has to be followed by a parameter port list or a port list (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3 26.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the header of ihi_bad imports ihi_pkg and then ends without a parameter port list or a port list
:expected_stderr_regex: test_illegal_interface_header_import_without_port_list\.sv:36:
*/
// IEEE 1800-2023 §25.3: a package import declaration in an
// interface_ansi_header shall be followed by a parameter_port_list, a
// list_of_port_declarations or both (footnote 1 of Syntax 25-1, also in
// 26.4). The headers of ihi_ports, ihi_params and ihi_empty follow the
// import with a port list, a parameter port list and an empty port list,
// which are legal. The header of ihi_bad ends right after its import.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator accept
// the design.

package ihi_pkg;
  typedef logic [3:0] nib_t;
endpackage

interface ihi_ports import ihi_pkg::*; (input nib_t a);
endinterface

interface ihi_params import ihi_pkg::*; #(parameter nib_t P = 4'd1);
endinterface

interface ihi_empty import ihi_pkg::*; ();
endinterface

interface ihi_bad import ihi_pkg::*; ;   // illegal: no list after the import
endinterface

module test_illegal_interface_header_import_without_port_list;
endmodule
