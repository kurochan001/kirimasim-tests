/*
:name: test_genvar_constant_primary_in_loop_generate
:description: Inside loop generate constructs a genvar is a constant primary in the loop scheme (a multiplying iteration and an inner bound taken from the outer genvar), in a vector width, a parameter override, a case generate selector and localparam values, giving one value per genvar value (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 27.5 A.4.2 A.8.4 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_genvar_constant_primary_in_loop_generate.expected
*/
// IEEE 1800-2023 §27.4 with footnote 44 of A.10: a genvar identifier is a
// constant primary (A.8.4) within a loop generate construct. In the loop
// scheme it is the loop index; inside the generate block, the implicit
// localparam of the same name has the genvar value of that instance, usable
// wherever a constant is.
//
// The outer loop k = 1; k < 20; k = k * 3 elaborates g[1], g[3] and g[9]. In
// each block, v is logic [k:0] (k + 1 bits), u is gv_sub with W = k + 1, the
// case generate on k % 4 gives R = 10 for 1, 30 for 3 and 10 again for 9
// (9 % 4 = 1), and the inner loop j = 0; j < k; j += 2 elaborates h[j] with
// PROD = k * 10 + j, for j = 0 (k 1), 0 2 (k 3) and 0 2 4 6 8 (k 9).

module gv_sub #(parameter int W = 1);
  logic [W-1:0] r;
endmodule

module test_genvar_constant_primary_in_loop_generate;
  genvar k, j;

  for (k = 1; k < 20; k = k * 3) begin : g
    logic [k:0] v;
    gv_sub #(.W(k + 1)) u ();

    case (k % 4)
      1: begin : c
        localparam int R = 10;
      end
      3: begin : c
        localparam int R = 30;
      end
      default: begin : c
        localparam int R = -1;
      end
    endcase

    for (j = 0; j < k; j += 2) begin : h
      localparam int PROD = k * 10 + j;
    end
  end

  initial begin
    $display("g[1]: v=%0d sub=%0d R=%0d", $bits(g[1].v), $bits(g[1].u.r), g[1].c.R);
    $display("g[3]: v=%0d sub=%0d R=%0d", $bits(g[3].v), $bits(g[3].u.r), g[3].c.R);
    $display("g[9]: v=%0d sub=%0d R=%0d", $bits(g[9].v), $bits(g[9].u.r), g[9].c.R);
    $display("inner: %0d %0d %0d %0d", g[1].h[0].PROD, g[3].h[2].PROD, g[9].h[4].PROD,
             g[9].h[8].PROD);
  end
endmodule
