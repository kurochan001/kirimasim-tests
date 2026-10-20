/*
:name: test_genvar_hierarchical_reference
:description: The localparam that a loop generate block gets for its genvar can be read through a hierarchical name such as g[1].i (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.6 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_genvar_hierarchical_reference.expected
*/
// IEEE 1800-2023 §27.4: each block that a loop generate construct creates
// has an implicit localparam with the name of the genvar and the value it
// had for that block. Like a localparam declared in the block, it can be
// named from outside through a hierarchical name (23.6): g[1].i is 1, the
// nested h's g[1].h[1].j is 1, also through $root (23.3.1), in a continuous
// assignment and in an expression.

module test_genvar_hierarchical_reference;
  for (genvar i = 0; i < 3; i++) begin : g
    localparam int DEP = 20 + i;
    for (genvar j = 0; j < 2; j++) begin : h
      int w = 100 * i + j;
    end
  end

  int a_ca;
  assign a_ca = g[2].i;

  initial begin
    #1;
    $display("g[0].i=%0d g[1].i=%0d g[2].i (assign)=%0d", g[0].i, g[1].i, a_ca);
    $display("$root: %0d, g[1].h[1].j=%0d, g[1].i + 5 = %0d",
             $root.test_genvar_hierarchical_reference.g[1].i, g[1].h[1].j, g[1].i + 5);
    $display("g[1].DEP=%0d g[1].h[1].w=%0d", g[1].DEP, g[1].h[1].w);
  end
endmodule
