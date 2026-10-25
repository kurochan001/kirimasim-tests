/*
:name: test_genvar_declaration_lists
:description: genvar declarations with a list of two names and with one name, each genvar then driving its own loop generate construct, observed through the local parameters and the block names that the loops create (IEEE 1800-2023 Sections 27.4, A.2.1.3, A.2.3)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 A.2.1.3 A.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_genvar_declaration_lists.expected
*/
// IEEE 1800-2023 A.2.1.3: a genvar declaration is the keyword genvar, a list
// of genvar names and a semicolon; A.2.3: the list is one or more names
// separated by commas. §27.4: each genvar declared this way can be the index
// variable of a loop generate construct, and each generated block is named
// by the value of the genvar, so gi and gj of the same declaration are two
// independent variables: row[gi].col[gj].V is gi * 10 + gj. gk, from a
// second declaration, counts down by 2 from 4, so the blocks are down[4] and
// down[2] and their K is 4 and 2.

module test_genvar_declaration_lists;
  genvar gi, gj;
  genvar gk;

  for (gi = 0; gi < 3; gi = gi + 1) begin : row
    for (gj = 0; gj < 2; gj = gj + 1) begin : col
      localparam int V = gi * 10 + gj;
    end
  end

  for (gk = 4; gk > 0; gk = gk - 2) begin : down
    localparam int K = gk;
  end

  initial begin
    $display("row[0].col[1].V=%0d row[2].col[0].V=%0d row[2].col[1].V=%0d", row[0].col[1].V,
             row[2].col[0].V, row[2].col[1].V);
    $display("down[4].K=%0d down[2].K=%0d", down[4].K, down[2].K);
  end
endmodule
