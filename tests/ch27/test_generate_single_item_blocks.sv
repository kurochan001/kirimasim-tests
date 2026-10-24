/*
:name: test_generate_single_item_blocks
:description: a loop or conditional generate block of a single item without begin-end is still a scope of its own, as named begin-end blocks are (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_single_item_blocks.expected
*/
// IEEE 1800-2023 §27.4 and §27.5: the generate block of a loop, if or case
// generate may be named or unnamed, and may be a single item without
// begin-end. Such a block is still a generate block: each instance of it is
// a separate scope and a new level of hierarchy.
// Here single-item blocks declare a variable x, or an instance u of module
// single_item_leaf, in every iteration of two loops and in an if, an else
// and a case generate. The module itself also has a variable x and an
// instance u; all these declarations only coexist if every block instance
// is a scope of its own, and the module's x keeps its value 1. Named
// begin-end blocks nl and nc show their own x by hierarchical name. Every
// instance of the leaf module prints its parameter at that time.

module single_item_leaf #(parameter int K = 0) ();
  initial #(K) $display("leaf K=%0d", K);
endmodule

module test_generate_single_item_blocks;
  localparam int P = 1;
  int x = 1;
  single_item_leaf #(.K(6)) u ();

  for (genvar i = 0; i < 3; i++) int x = i + 100;
  for (genvar i = 0; i < 2; i++) single_item_leaf #(.K(2 + i)) u ();
  for (genvar i = 0; i < 2; i++) begin : nl
    int x = i + 200;
  end

  if (P == 1) int x = 5;
  else int x = 6;
  case (P)
    1: int x = 7;
    default: int x = 8;
  endcase
  if (P == 1) single_item_leaf #(.K(4)) u ();
  else single_item_leaf #(.K(5)) u ();
  if (P == 1) begin : nc
    int x = 9;
  end

  initial #1 $display("x=%0d nl[0].x=%0d nl[1].x=%0d nc.x=%0d", x, nl[0].x, nl[1].x, nc.x);
endmodule
