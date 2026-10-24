/*
:name: test_precedence_dist_takes_whole_expression
:description: dist, on the precedence row of the relational operators, applies to the whole arithmetic, shift or relational expression written before it in a constraint (IEEE 1800-2023 Section 11.3.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 18.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_dist_takes_whole_expression.expected
*/
// IEEE 1800-2023 §11.3.2, Table 11-2: dist is on the row of < <= > >= and
// inside, below the arithmetic and shift operators, and associates left. In a
// constraint (§18.5.3) a dist item is also a membership test: the expression
// before dist has to take one of the listed values with a nonzero weight.
// x + 1 << 1 dist {8 := 1} groups as ((x + 1) << 1) dist {8}, so x is 3
// (grouping x + (1 << 1) would give 6). y * 2 - 1 < 6 dist {0 := 1} groups as
// ((y * 2 - 1) < 6) dist {0}, so the comparison is false and, with y in 0
// to 4, y is 4. Each constraint has a single solution, so every call gives
// the same values.
// Icarus Verilog 13.0 does not support randomize.

class prec_dist;
  rand int x, y;
  constraint c_x { x inside {[0:9]}; x + 1 << 1 dist {8 := 1}; }
  constraint c_y { y inside {[0:4]}; y * 2 - 1 < 6 dist {0 := 1}; }
endclass

module test_precedence_dist_takes_whole_expression;
  prec_dist o = new;

  initial begin
    repeat (3) begin
      if (o.randomize()) $display("x=%0d y=%0d", o.x, o.y);
      else $display("randomize failed");
    end
  end
endmodule
