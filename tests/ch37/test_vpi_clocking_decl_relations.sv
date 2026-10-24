/*
:name: test_vpi_clocking_decl_relations
:description: a clocking block iterates the property and sequence declarations written in it, which lead back to it, its clocking io declarations lead back to it, and its full name is its hierarchical name (IEEE 1800-2023 Section 37.48)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.48 14.3 37.51 37.53
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_clocking_decl_relations.c
:expected_stdout: @test_vpi_clocking_decl_relations.expected
*/
// IEEE 1800-2023 §37.48: a clocking block has one-to-many relations to the
// property and sequence declarations that are clocking items in it (14.3) and
// to its clocking io decls, and each of these has a one-to-one relation back
// to the clocking block (vpiClockingBlock). cb1 declares the property p_one
// and the sequence s_one and cb2 the sequence s_two only, so each iteration
// returns the declarations of its own block, and each declaration and io
// decl leads to the block it is written in. vpiFullName of a clocking block is
// its hierarchical name, through the generate block g for cb3. The clocking
// blocks are found by their names; lists are sorted.

module test_vpi_clocking_decl_relations;
  logic clk = 1'b0, a = 1'b0, b, c = 1'b0;

  clocking cb1 @(posedge clk);
    input a;
    output b;
    property p_one;
      a;
    endproperty
    sequence s_one;
      a ##1 a;
    endsequence
  endclocking

  clocking cb2 @(negedge clk);
    input a, c;
    sequence s_two;
      c;
    endsequence
  endclocking

  if (1) begin : g
    clocking cb3 @(posedge clk);
      input c;
    endclocking
  end

  initial #1 $vt_clocking;
endmodule
