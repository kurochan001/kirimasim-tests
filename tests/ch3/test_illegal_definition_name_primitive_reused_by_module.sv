/*
:name: test_illegal_definition_name_primitive_reused_by_module
:description: a primitive and a module defined outside all other declarations cannot have the same name, because both names are in the definitions name space (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module dn_pm_name reuses the name of the primitive dn_pm_name, and primitive and module names share the definitions name space
:expected_stderr_regex: test_illegal_definition_name_primitive_reused_by_module\.sv:36:|test_illegal_definition_name_primitive_reused_by_module\.sv:28:
*/
// IEEE 1800-2023 §3.13 a): the definitions name space holds the names of
// all modules, primitives, programs and interfaces that are not nested in
// another declaration. Once one of them has a name, no other of these four
// kinds can be defined with that name.
// The user-defined primitive dn_pm_name, an inverter, and then the module
// dn_pm_name are defined at the top level of this file. The module is the
// second definition, so its line is where the error belongs; the line of
// the primitive is accepted as the place as well, since the conflict
// involves both. Nothing else is an error: with another name for the
// module, the design is legal.
// Icarus Verilog 13.0 accepts the design without a message, and the 5.054
// release of the Verilator tool reports the second definition only as a
// warning (MODDUP), so the expected result follows the clause alone.

primitive dn_pm_name(output q, input a);
  table
  // a : q
     0 : 1;
     1 : 0;
  endtable
endprimitive

module dn_pm_name;  // illegal: the name of the primitive above
  logic [3:0] state;
endmodule

module test_illegal_definition_name_primitive_reused_by_module;
  initial $display("the design must be rejected");
endmodule
