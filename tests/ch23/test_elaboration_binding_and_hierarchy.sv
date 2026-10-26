/*
:name: test_elaboration_binding_and_hierarchy
:description: elaboration binds instances, builds generate-block hierarchy, computes parameters and connects nets (IEEE 1800-2023 Section 23.10.4)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_binding_and_hierarchy.expected
*/
// Elaboration takes place between parsing and simulation: it binds each
// instance to its module, builds the hierarchy including generate block
// names, computes parameter values, resolves hierarchical names and
// establishes net connectivity. The design below observes all of these:
// u0 with W = 4 inverts a, the generate block gen holds two more leaves
// with W = g + 2, gen[1].u.a is the part-select a[2:0], and the
// hierarchical names resolve to the instances that elaboration built.

module leaf #(parameter int W = 4)
              (input logic [W-1:0] a, output logic [W-1:0] y);
  assign y = ~a;
endmodule

module test_elaboration_binding_and_hierarchy;
  logic [3:0] a;
  wire [3:0] y0;
  leaf #(.W(4)) u0 (.a(a), .y(y0));
  genvar g;
  generate
    for (g = 0; g < 2; g = g + 1) begin : gen
      leaf #(.W(g + 2)) u (.a(a[g + 1:0]), .y());
    end
  endgenerate

  initial begin
    a = 4'b1010;
    #1;
    $display("u0.y=%b", u0.y);
    $display("gen1.a=%b w=%0d", gen[1].u.a, $bits(gen[1].u.a));
    $display("root=%b", test_elaboration_binding_and_hierarchy.u0.y);
  end
endmodule
