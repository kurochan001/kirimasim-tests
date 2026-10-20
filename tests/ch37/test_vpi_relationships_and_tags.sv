/*
:name: test_vpi_relationships_and_tags
:description: One-to-one relationships are followed with vpi_handle, such as from a net to its module, and tags such as vpiLeftRange and vpiRightRange name which of several expressions of a part-select is wanted (IEEE 1800-2023 Section 37.3.1)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.1 37.22 38.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_relationships_and_tags.c
:expected_stdout: @test_vpi_relationships_and_tags.expected
*/
// IEEE 1800-2023 §37.3.1: objects are reached through relationships from other
// objects or by name; vpi_handle (38.21) follows one-to-one relationships, so
// vpiModule leads from the net bus to the instance c that holds it. Where an
// object refers to several expressions, tags name which one: a part-select has
// a left and a right range, reached with vpiLeftRange and vpiRightRange rather
// than vpiExpr. Properties come from the vpi_get family. The continuous
// assignment to y reads bus[5:2], whose value is 1101.

module test_vpi_relationships_and_tags_child (input logic [7:0] w8, output logic [3:0] y);
  wire [7:0] bus = w8;
  assign y = bus[5:2];
endmodule

module test_vpi_relationships_and_tags;
  logic [7:0] w = 8'b1011_0100;
  logic [3:0] y;

  test_vpi_relationships_and_tags_child c(w, y);

  initial #1 $vt_walk;
endmodule
