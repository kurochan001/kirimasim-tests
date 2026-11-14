/*
:name: test_illegal_package_name_reused_in_other_file
:description: two packages cannot have the same name, even when they are defined in different source files, because package names are in one package name space for all compilation units (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: package_name_first.sv
:should_fail_because: the package pn_file_pkg reuses the name of the package pn_file_pkg that the file compiled before it defines, and package names share one name space across all compilation units
:expected_stderr_regex: (test_illegal_package_name_reused_in_other_file\.sv:31:|package_name_first\.sv:4:)
*/
// IEEE 1800-2023 §3.13 b): the package name space holds the names of the
// packages of all compilation units. Once a name is used for a package, no
// other package can be declared with that name in any compilation unit.
// The file that :files: names, compiled before this one, defines the package
// pn_file_pkg; this file defines another package pn_file_pkg. Whether the two
// files are one compilation unit or two is left to the tool (§3.12.1), and
// the name is reused in either case. The package in this file is the second
// definition, so its line is where the error belongs; the first definition,
// in the other file, is accepted as the place as well, since the conflict
// involves both. Neither package is used, and nothing else in the two files
// is an error: with another name for this package, the design is legal.
// Icarus Verilog 13.0 stops with a syntax error on the line of the second
// package, which does not say that the name is reused, so its rejection
// is not counted; the 5.054 release of the Verilator tool reports the
// second package only as a warning (MODDUP) and builds the design.

package pn_file_pkg;  // illegal: the name of a package in the other file
  parameter int VALUE = 2;
endpackage

module test_illegal_package_name_reused_in_other_file;
  initial $display("the design must be rejected");
endmodule
