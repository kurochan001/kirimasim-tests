/*
:name: test_generate_syntax_forms
:description: loop generates with a separate or an inline genvar and each form of iteration, if-else and case generates with constant selections and a default, and labeled, unlabeled and single-item generate blocks (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.4 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_syntax_forms.expected
*/
// IEEE 1800-2023 §27.3, Syntax 27-1: a loop generate initializes a genvar,
// declared before or in the loop header, tests it and updates it by an
// assignment, a compound assignment, or a prefix or postfix increment or
// decrement. An if generate has an optional else and a case generate has
// lists of constant items and a default. A generate block is one item, or
// begin-end with an optional label, which may be repeated after end, and
// generate constructs may sit in an optional generate region.
// Each named block below holds a variable set from its genvar or from
// its alternative, and the module prints them by hierarchical name
// (§27.4, §27.5), so every loop shows which genvar values it went through
// and every conditional which alternative it chose. The single-item if
// generate drives net y.
// The 5.052 release of Verilator rejects the references to down, pre and
// post, but not to up, as undefined; it accepts them when the module has no
// pick or no cs generate construct.

module test_generate_syntax_forms;
  localparam int SEL = 3;
  genvar g;
  wire y;

  generate
    for (g = 0; g < 3; g = g + 1) begin : up
      int V = g * 10;
    end
  endgenerate

  for (genvar i = 6; i > 0; i -= 2) begin : down
    localparam int V = i;
  end

  for (genvar j = 0; j < 2; ++j) begin : pre
    localparam int V = j + 100;
  end

  for (genvar n = 1; n >= 0; n--) begin : post
    localparam int V = n + 200;
  end

  if (SEL < 2) begin : pick
    int S = 1;
  end else begin : pick
    int S = 2;
  end

  case (SEL)
    0, 1: begin : cs
      int W = 1;
    end
    2, 3: begin : cs
      int W = 23;
    end : cs
    default: begin : cs
      int W = 99;
    end
  endcase

  case (SEL + 4)
    0: begin : dc
      int W = 0;
    end
    default: begin : dc
      int W = 7;
    end
  endcase

  if (SEL == 3) assign y = 1'b1;
  else assign y = 1'b0;

  initial begin
    #1;
    $display("up: %0d %0d %0d", up[0].V, up[1].V, up[2].V);
    $display("down: %0d %0d %0d", down[6].V, down[4].V, down[2].V);
    $display("pre: %0d %0d, post: %0d %0d", pre[0].V, pre[1].V, post[1].V, post[0].V);
    $display("pick: %0d, cs: %0d, dc: %0d, y: %b", pick.S, cs.W, dc.W, y);
  end
endmodule
