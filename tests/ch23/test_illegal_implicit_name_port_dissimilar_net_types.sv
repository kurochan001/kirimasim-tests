/*
:name: test_illegal_implicit_name_port_dissimilar_net_types
:description: A .name connection between nets whose dissimilar net types call for a warning in a named connection is an error (IEEE 1800-2023 Section 23.3.2.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.3 23.3.3.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the .a connection of u joins the wor net a of the instantiating module to the wand port a, a pair for which Table 23-1 asks for a warning
:expected_stderr_regex: test_illegal_implicit_name_port_dissimilar_net_types\.sv:32:
*/
// IEEE 1800-2023 §23.3.2.3: an implicit .name connection between nets of two
// dissimilar net types is an error where the same connection made by an
// explicit named connection draws a warning (23.3.3.7). By Table 23-1 an
// internal wand net with an external wor net gives the external type and a
// warning. The instance ok makes that connection explicitly, .a(a), which is
// legal; u makes it with .a.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator accept
// the design.

module dnt_child(input wand a, output wire y);
  assign y = a;
endmodule

module test_illegal_implicit_name_port_dissimilar_net_types;
  wor a;
  wire y1, y2;
  assign a = 1'b1;
  dnt_child ok (.a(a), .y(y1));
  dnt_child u (.a, .y(y2));   // illegal: wor to wand by .name
endmodule
