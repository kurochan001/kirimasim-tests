/*
:name: test_vpi_untagged_relation_access
:description: A relation drawn without a tag is accessed with the type made of vpi and the capitalized words of the target object, vpiModule, vpiNet and vpiNamedEvent; its one-to-one relations (single arrows) are followed with vpi_handle and its one-to-many relations (double arrows) with vpi_iterate and vpi_scan (IEEE 1800-2023 Sections 37.3 and 37.4.3)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3 37.4.3 37.5 37.10 37.16 37.27
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_untagged_relation_access.c
:expected_stdout: @test_vpi_untagged_relation_access.expected
*/
// IEEE 1800-2023 §37.3, §37.4.3: for a relation drawn without a tag, the
// type passed to the access routine is "vpi" followed by the words in the
// enclosure of the target object, each word capitalized: "module" gives
// vpiModule, "net" vpiNet and the two words "named event" vpiNamedEvent.
// A single arrow is a one-to-one relation, followed with vpi_handle; a
// double arrow is a one-to-many relation, followed with vpi_iterate and then
// vpi_scan until it returns NULL.
//
// The application uses double arrows from a module to its module instances
// (37.5), its nets (37.16) and its named events (37.10), and single arrows
// from a net (37.16) and from a named event (37.27) to the module that holds
// it. The top module holds the instances u1 and u2, the nets in and mid and
// the named events start and stop; each instance holds the nets a, inv and y
// and the named event done; the always blocks trigger the named events,
// which changes nothing that is printed. Lists are sorted by name, and each
// single arrow prints the full name of the module it leads to.

module test_vpi_untagged_relation_access_leaf(input wire a, output wire y);
  wire inv;
  event done;

  assign inv = ~a;
  assign y = inv;

  always @(inv) -> done;
endmodule

module test_vpi_untagged_relation_access;
  wire in, mid;
  event start, stop;

  assign in = 1'b0;

  test_vpi_untagged_relation_access_leaf u1(.a(in), .y(mid));
  test_vpi_untagged_relation_access_leaf u2(.a(mid), .y());

  always @(start) -> stop;

  initial #1 $vt_walk;
endmodule
