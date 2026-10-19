/*
:name: test_generate_block_select_expr
:description: The index of a generate block array or an instance array in a hierarchical name can be any constant expression (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 27.4 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_block_select_expr.expected
*/
// IEEE 1800-2023 §23.6, §27.4: a hierarchical name can select one block of a
// loop generate construct, or one instance of an array of instances (23.3.3.5),
// with a constant expression, which may use the genvar of the enclosing loop.
// g[gi+0], g[(gi)] and g[gi] all name the same block; g[1-gi] and
// r[(gi+1)%3] name a neighbouring one. Reads and writes through such names reach
// the selected block.

module generate_select_leaf #(parameter ID = 0);
  reg [7:0] v;
  initial v = 8'h20 + ID;
endmodule

module test_generate_block_select_expr;
  reg [7:0] mv = 8'hBB;
  int errors = 0;

  generate_select_leaf ua[0:1]();      // array of instances, ID = 0

  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : g
      reg [7:0] v;
      initial v = 8'h10 + gi;
      reg [7:0] bare, plus0, times1, paren, flip, other, up;
      reg [7:0] arr_bare, arr_expr;
      initial #1 begin
        bare     = g[gi].v;
        plus0    = g[gi+0].v;
        times1   = g[gi*1].v;
        paren    = g[(gi)].v;
        flip     = g[1-gi].v;           // the other block
        other    = h[0].w;              // a block of another loop
        up       = mv;                  // a module variable
        arr_bare = ua[gi].v;            // an instance of the array
        arr_expr = ua[(gi)].v;
      end
    end
    for (gi = 0; gi < 3; gi = gi + 1) begin : r
      reg [7:0] v;
      initial v = 8'h10 + gi;
      reg [7:0] nxt, prv;
      reg [7:0] wtarget;
      initial wtarget = 8'h00;
      initial #1 begin
        nxt = r[(gi+1)%3].v;
        prv = r[(gi+2)%3].v;
      end
      initial #2 r[(gi+1)%3].wtarget = 8'hA0 + gi;   // a write through the name
    end
    for (gi = 0; gi < 1; gi = gi + 1) begin : h
      reg [7:0] w;
      initial w = 8'hAA;
    end
  endgenerate

  initial #4 begin
    if (g[0].bare !== 8'h10 || g[1].bare !== 8'h11) begin
      $display("FAIL g[gi]: %0h %0h (expect 10 11)", g[0].bare, g[1].bare);
      errors++;
    end
    if (g[0].plus0 !== 8'h10 || g[1].plus0 !== 8'h11) begin
      $display("FAIL g[gi+0]: %0h %0h (expect 10 11)", g[0].plus0, g[1].plus0);
      errors++;
    end
    if (g[0].times1 !== 8'h10 || g[1].times1 !== 8'h11) begin
      $display("FAIL g[gi*1]: %0h %0h (expect 10 11)", g[0].times1, g[1].times1);
      errors++;
    end
    if (g[0].paren !== 8'h10 || g[1].paren !== 8'h11) begin
      $display("FAIL g[(gi)]: %0h %0h (expect 10 11)", g[0].paren, g[1].paren);
      errors++;
    end
    if (g[0].flip !== 8'h11 || g[1].flip !== 8'h10) begin
      $display("FAIL g[1-gi]: %0h %0h (expect 11 10)", g[0].flip, g[1].flip);
      errors++;
    end
    if (g[0].other !== 8'hAA || g[1].other !== 8'hAA) begin
      $display("FAIL h[0].w: %0h %0h (expect aa aa)", g[0].other, g[1].other);
      errors++;
    end
    if (g[0].up !== 8'hBB || g[1].up !== 8'hBB) begin
      $display("FAIL mv: %0h %0h (expect bb bb)", g[0].up, g[1].up);
      errors++;
    end
    if (g[0].arr_bare !== 8'h20 || g[1].arr_bare !== 8'h20) begin
      $display("FAIL ua[gi]: %0h %0h (expect 20 20)", g[0].arr_bare, g[1].arr_bare);
      errors++;
    end
    if (g[0].arr_expr !== 8'h20 || g[1].arr_expr !== 8'h20) begin
      $display("FAIL ua[(gi)]: %0h %0h (expect 20 20)", g[0].arr_expr, g[1].arr_expr);
      errors++;
    end
    if (r[0].nxt !== 8'h11 || r[1].nxt !== 8'h12 || r[2].nxt !== 8'h10) begin
      $display("FAIL ring nxt: %0h %0h %0h (expect 11 12 10)",
               r[0].nxt, r[1].nxt, r[2].nxt);
      errors++;
    end
    if (r[0].prv !== 8'h12 || r[1].prv !== 8'h10 || r[2].prv !== 8'h11) begin
      $display("FAIL ring prv: %0h %0h %0h (expect 12 10 11)",
               r[0].prv, r[1].prv, r[2].prv);
      errors++;
    end
    if (r[0].wtarget !== 8'hA2 || r[1].wtarget !== 8'hA0 ||
        r[2].wtarget !== 8'hA1) begin
      $display("FAIL ring write: %0h %0h %0h (expect a2 a0 a1)",
               r[0].wtarget, r[1].wtarget, r[2].wtarget);
      errors++;
    end
    if (errors == 0)
      $display("TEST PASSED");
    else
      $display("TEST FAILED: %0d error(s)", errors);
    $finish;
  end
endmodule
