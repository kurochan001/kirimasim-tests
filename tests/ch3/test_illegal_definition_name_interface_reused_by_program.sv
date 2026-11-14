/*
:name: test_illegal_definition_name_interface_reused_by_program
:description: an interface and a program defined outside all other declarations cannot have the same name, because both names are in the definitions name space (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the program dn_ip_name reuses the name of the interface dn_ip_name, and interface and program names share the definitions name space
:expected_stderr_regex: test_illegal_definition_name_interface_reused_by_program\.sv:30:|test_illegal_definition_name_interface_reused_by_program\.sv:26:
*/
// IEEE 1800-2023 §3.13 a): the definitions name space holds the names of
// all modules, primitives, programs and interfaces that are not nested in
// another declaration. Once one of them has a name, no other of these four
// kinds can be defined with that name.
// The interface dn_ip_name and then the program dn_ip_name are defined at the
// top level of this file. The program is the second definition, so its
// line is where the error belongs; the line of the interface is accepted as
// the place as well, since the conflict involves both. Nothing else is an
// error: with another name for the program, the design is legal.
// The 5.054 release of the Verilator tool reports the second definition
// only as a warning (MODDUP) and builds the design.

interface dn_ip_name;
  logic [3:0] state;
endinterface

program dn_ip_name;  // illegal: the name of the interface above
  logic [3:0] count;
endprogram

module test_illegal_definition_name_interface_reused_by_program;
  initial $display("the design must be rejected");
endmodule
