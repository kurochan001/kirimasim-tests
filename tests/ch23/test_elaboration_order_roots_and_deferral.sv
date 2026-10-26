/*
:name: test_elaboration_order_roots_and_deferral
:description: Elaboration starts from the top-level modules, finalizes the parameters of each starting point before it evaluates the generate constructs, expands the generated blocks as the next starting points, and defers a defparam whose target exists only after a generate construct is evaluated (IEEE 1800-2023 Section 23.10.4.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.10.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_elaboration_order_roots_and_deferral.expected
*/
// IEEE 1800-2023 §23.10.4.1: the list of starting points is initialized with
// the top-level modules; the hierarchy below each starting point is expanded
// without elaborating generate constructs, and every parameter met is given
// its final value from its default, its overrides and the defparam
// statements whose targets can be resolved; a defparam whose target cannot
// be resolved yet is deferred to the next iteration. Then each generate
// construct met is evaluated, and the generated block instantiations are the
// next list of starting points, repeated until the list is empty. The module
// eo_wrap is one top-level module and it instantiates eo_top1 with N = 3, so
// the generate loop creates the blocks g[0], g[1] and g[2] and their nested
// if/else blocks even and odd. A tool that evaluated the loop before the
// parameter N was finalized would create two blocks and have no g[2]. The
// defparam of g[1].odd.u_leaf.W names a target that exists only after the
// generate loop is evaluated, so it is deferred and then sets W to 42 where
// the instance assignment gives 21. The module eo_top2 is the other
// top-level module and is elaborated once; eo_leaf and eo_top1 are
// instantiated, so they are not starting points and are elaborated only
// where they are instantiated. The display times 1 and 2 fix the order.

module eo_leaf #(parameter int W = 1) ();
  task show;
    $display("leaf W=%0d", W);
  endtask
endmodule

module eo_top1 #(parameter int N = 2) ();
  defparam g[1].odd.u_leaf.W = 42;

  generate
    for (genvar i = 0; i < N; i = i + 1) begin : g
      if (i % 2 == 0) begin : even
        eo_leaf #(.W(10 + i)) u_leaf ();
      end
      else begin : odd
        eo_leaf #(.W(20 + i)) u_leaf ();
      end
    end
  endgenerate

  initial begin
    #1 begin
      g[0].even.u_leaf.show();
      g[1].odd.u_leaf.show();
      g[2].even.u_leaf.show();
      $display("top1 N=%0d done", N);
    end
  end
endmodule

module eo_top2;
  eo_leaf #(.W(99)) u_leaf ();
  initial begin
    #2 begin
      u_leaf.show();
      $display("top2 done");
    end
  end
endmodule

module eo_wrap;
  eo_top1 #(.N(3)) u_top1 ();
endmodule
