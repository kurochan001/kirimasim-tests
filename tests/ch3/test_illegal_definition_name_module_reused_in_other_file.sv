/*
:name: test_illegal_definition_name_module_reused_in_other_file
:description: a module defined in one source file and an interface defined outside all other declarations in another source file cannot have the same name, because both names are in the one definitions name space of the design, whatever the compilation units (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: definition_name_module_first.sv
:should_fail_because: the interface dn_file_name reuses the name of the module dn_file_name, which the file compiled before it defines, and module and interface names share the definitions name space across all compilation units
:expected_stderr_regex: (test_illegal_definition_name_module_reused_in_other_file\.sv:30:|definition_name_module_first\.sv:4:)
*/
// IEEE 1800-2023 §3.13 a): the definitions name space holds the names of
// all modules, primitives, programs and interfaces that are not nested in
// another declaration. Once one of them has a name, no other of these four
// kinds can be defined with that name in any compilation unit.
// The file that :files: names, compiled before this one, defines the module
// dn_file_name. This file defines an interface dn_file_name at the top
// level. Whether the two files are one compilation unit or two is left to
// the tool (§3.12.1), and the name is reused in either case. The interface
// is the second definition, so its line is where the error belongs; the
// first definition, in the other file, is accepted as the place as well,
// since the conflict involves both. Nothing else in the two files is an
// error: with another name for the interface, the design is legal.
// The 5.054 release of the Verilator tool reports the second definition
// only as a warning (MODDUP) and builds the design.

interface dn_file_name;  // illegal: the name of a module in the other file
  logic [3:0] state;
endinterface

module test_illegal_definition_name_module_reused_in_other_file;
  initial $display("the design must be rejected");
endmodule
