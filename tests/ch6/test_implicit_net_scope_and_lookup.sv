/*
:name: test_implicit_net_scope_and_lookup
:description: An undeclared name on the left of a continuous assignment, in a port connection or in a primitive terminal becomes a scalar net of the default net type in the scope of the reference, and only when lookup finds no declaration (IEEE 1800-2023 Section 6.10)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.10 22.8 23.9 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_net_scope_and_lookup.expected
*/
// IEEE 1800-2023 §6.10: when a name has no declaration that lookup (23.9) can
// find from the scope of the reference, its use on the left of a continuous
// assignment, in the port connections of an instance or in the terminals of a
// primitive declares an implicit scalar net of the default net type, here wand
// (22.8), in that scope.
// top_and gets two drivers, so it shows wand resolution. g_found assigns to
// outer and connects an instance output to wide, which the module declares, so
// no implicit net is made there and the module's outer and 4-bit wide get the
// values. g_a and g_b each declare their own loc
// (27.5), so the two do not merge into one wand net. The 4-bit output of the
// leaf instance in g_a is connected to the undeclared narrow, which becomes a
// scalar and keeps only the lowest bit; the primitive terminal term in g_a is
// one too.

`default_nettype wand

module test_implicit_net_scope_and_lookup_leaf(input logic [3:0] d, output logic [3:0] q);
  assign q = d;
endmodule

module test_implicit_net_scope_and_lookup;
  logic [3:0] src = 4'b1101;
  logic outer;
  logic [3:0] wide;

  assign top_and = src[0];
  assign top_and = src[1];

  if (1) begin : g_found
    assign outer = src[2];
    test_implicit_net_scope_and_lookup_leaf u(.d(src), .q(wide));
  end

  if (1) begin : g_a
    assign loc = src[0];
    test_implicit_net_scope_and_lookup_leaf u(.d(src), .q(narrow));
    buf b(term, src[3]);
  end

  if (1) begin : g_b
    assign loc = src[1];
  end

  initial begin
    #1 $display("top_and=%b bits=%0d", top_and, $bits(top_and));
    $display("outer=%b wide=%b", outer, wide);
    $display("g_a.loc=%b g_b.loc=%b", g_a.loc, g_b.loc);
    $display("g_a.narrow=%b bits=%0d g_a.term=%b bits=%0d", g_a.narrow, $bits(g_a.narrow),
             g_a.term, $bits(g_a.term));
  end
endmodule

`default_nettype wire
