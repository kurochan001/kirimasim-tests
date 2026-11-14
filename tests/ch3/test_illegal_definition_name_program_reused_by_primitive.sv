/*
:name: test_illegal_definition_name_program_reused_by_primitive
:description: a program and a primitive defined outside all other declarations cannot have the same name, because both names are in the definitions name space (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the primitive dn_pp_name reuses the name of the program dn_pp_name, and program and primitive names share the definitions name space
:expected_stderr_regex: test_illegal_definition_name_program_reused_by_primitive\.sv:32:|test_illegal_definition_name_program_reused_by_primitive\.sv:28:
*/
// IEEE 1800-2023 §3.13 a): the definitions name space holds the names of
// all modules, primitives, programs and interfaces that are not nested in
// another declaration. Once one of them has a name, no other of these four
// kinds can be defined with that name.
// The program dn_pp_name and then the user-defined primitive dn_pp_name, a
// buffer, are defined at the top level of this file. The primitive is the
// second definition, so its line is where the error belongs; the line of
// the program is accepted as the place as well, since the conflict
// involves both. Nothing else is an error: with another name for the
// primitive, the design is legal.
// Icarus Verilog 13.0 accepts the design without a message, and the 5.054
// release of the Verilator tool reports the second definition only as a
// warning (MODDUP), so the expected result follows the clause alone.

program dn_pp_name;
  logic [3:0] count;
endprogram

primitive dn_pp_name(output q, input a);  // illegal: the name of the program above
  table
  // a : q
     0 : 0;
     1 : 1;
  endtable
endprimitive

module test_illegal_definition_name_program_reused_by_primitive;
  initial $display("the design must be rejected");
endmodule
