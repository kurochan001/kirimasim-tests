/*
:name: test_clocking_scope_names
:description: A clocking block declared in a generate block is reached by its scope name, and its clockvars are resolved through the clocking block, also from another module by a hierarchical name (IEEE 1800-2023 Section 14.7)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.7 14.5 14.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_scope_names.expected
*/
// IEEE 1800-2023 §14.7: a clocking block is declared in a scope and its
// clockvars are named through it, as cb.d, not as d; the same names are used
// from other scopes, as u.g.cb.d. The clocking block here is inside generate
// block g of the producer, and the observer reaches it by the full
// hierarchical name. §14.5: d is a module signal and cb.d is its sampled
// value, taken 2 time units before each rising edge, so at 6 they differ.
// §14.6: the generate block is part of the name of the clocking block. The
// outputs q is driven through the clocking block with an output skew of 2.

`timescale 1ns/1ns

module scope_prod;
  logic clk = 0, d = 0, q = 0;

  always #5 clk = ~clk;

  generate
    if (1) begin : g
      clocking cb @(posedge clk);
        input #2 d;
        output #2 q;
      endclocking
    end
  endgenerate

  initial begin
    @(g.cb);                       // 5
    g.cb.q <= 1;
    #1 $display("prod t=%0t plain=%b sampled=%b", $time, d, g.cb.d);  // 6
    #2 $display("prod t=%0t q=%b", $time, q);                         // 8
    @(g.cb);                       // 15
    $display("prod t=%0t sampled=%b", $time, g.cb.d);
  end

  initial begin
    #4 d = 1;
  end
endmodule

module scope_obs;
  initial begin
    @(test_clocking_scope_names.u.g.cb);        // 5
    @(test_clocking_scope_names.u.g.cb);        // 15
    #1 $display("obs t=%0t sampled=%b", $time, test_clocking_scope_names.u.g.cb.d);
  end
endmodule

module test_clocking_scope_names;
  scope_prod u();
  scope_obs o();

  initial #40 $finish;
endmodule
