/*
:name: test_always_comb_reads_generate_scope_names
:description: always_comb procedures in generate blocks rerun when variables they read through hierarchical names in other generate blocks change (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1 23.6 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_reads_generate_scope_names.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: the implicit sensitivity of always_comb covers
// every variable it reads. That holds for a variable named through a
// hierarchical name (23.6) into a generate block (27.4), such as
// g[1].h[1].w read from another block of the same loop, or inner.b read
// from the block around it. When in changes, the always_comb procedures that
// compute w and b run, and then the ones that read them.

module test_always_comb_reads_generate_scope_names;
  logic [7:0] in = 8'h10;

  for (genvar i = 0; i < 2; i++) begin : g
    logic [7:0] t_hier, t_cont;
    for (genvar j = 0; j < 2; j++) begin : h
      logic [7:0] w;
      always_comb w = in + 8'(10 * i + j);
    end
    always_comb t_hier = g[1].h[1].w;
    assign t_cont = g[1].h[1].w;
  end

  if (1) begin : outer
    logic [7:0] b_up;
    if (1) begin : inner
      logic [7:0] b;
      always_comb b = in + 8'd3;
    end
    always_comb b_up = inner.b;
  end

  logic [7:0] direct;
  always_comb direct = outer.inner.b;

  initial begin
    #1 $display("in=%h: g[0].t_hier=%h g[0].t_cont=%h outer.b_up=%h direct=%h", in,
                g[0].t_hier, g[0].t_cont, outer.b_up, direct);
    in = 8'h20;
    #1 $display("in=%h: g[0].t_hier=%h g[0].t_cont=%h outer.b_up=%h direct=%h", in,
                g[0].t_hier, g[0].t_cont, outer.b_up, direct);
  end
endmodule
