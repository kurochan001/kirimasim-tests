/*
:name: test_equals_token_assignment_contexts
:description: the = of a continuous assignment, of a procedural continuous assignment and of a blocking procedural assignment gives each its own behavior, taken from the context of the token (IEEE 1800-2023 Section 10.4.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 10.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_equals_token_assignment_contexts.expected
*/
// IEEE 1800-2023 §10.4.1: the = of a blocking procedural assignment is also
// the assignment operator of continuous assignments and of procedural
// continuous assignments, so the context of = decides which assignment it
// is. §10.3: a continuous assignment, an assign statement outside any
// procedure, updates its target whenever its right-hand side changes.
// §10.6.1: a procedural continuous assignment, the assign statement inside a
// procedure, makes its variable follow the right-hand side and overrides the
// procedural assignments to that variable until deassign, after which the
// variable keeps its value until the next procedural assignment. A blocking
// assignment assigns the value once.
//
// All four targets get src = 1 first. When src becomes 2, the net w and the
// variable v_cont of the continuous assignments and v_pca of the procedural
// continuous assignment follow it, and v_blk keeps 1. The procedural
// assignment v_pca = 9 has no effect while the procedural continuous
// assignment is in force, so v_pca stays 2. After deassign, v_pca keeps 2
// when src becomes 3, and the procedural assignment v_pca = 9 then takes
// effect. The values are printed one time unit after each change.
// The 5.054 release of Verilator assigns v_pca only once at the procedural
// continuous assignment, as a blocking assignment would, so v_pca stays 1
// when src becomes 2 (§10.6.1).

module test_equals_token_assignment_contexts;
  logic [3:0] src;
  wire  [3:0] w;
  logic [3:0] v_cont, v_pca, v_blk;

  assign w = src;
  assign v_cont = src;

  initial begin
    src = 4'd1;
    v_blk = src;
    assign v_pca = src;
    #1 $display("start: w=%0d v_cont=%0d v_pca=%0d v_blk=%0d", w, v_cont, v_pca, v_blk);
    src = 4'd2;
    #1 $display("src=2: w=%0d v_cont=%0d v_pca=%0d v_blk=%0d", w, v_cont, v_pca, v_blk);
    v_pca = 4'd9;
    #1 $display("v_pca=9 during assign: v_pca=%0d", v_pca);
    deassign v_pca;
    src = 4'd3;
    #1 $display("deassign, src=3: w=%0d v_cont=%0d v_pca=%0d v_blk=%0d",
                w, v_cont, v_pca, v_blk);
    v_pca = 4'd9;
    #1 $display("v_pca=9 after deassign: v_pca=%0d", v_pca);
  end
endmodule
