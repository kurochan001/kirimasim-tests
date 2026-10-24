/*
:name: test_illegal_generate_nested_same_genvar
:description: two nested loop generates cannot use the same genvar, because inside the outer block its name means the block's localparam (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the inner loop of block row uses the genvar r of the outer loop, whose name inside row is the implicit localparam r
:expected_stderr_regex: test_illegal_generate_nested_same_genvar\.sv:30:
*/
// IEEE 1800-2023 §27.4: each block of a loop generate has an implicit
// localparam with the name of the genvar, so inside the block that name is
// the localparam and not the genvar. A loop nested in the block therefore
// cannot use the genvar of the outer loop. Blocks col use their own genvar c
// and read the localparam r, which is legal; blocks row also contain a loop
// that assigns r. The 5.052 release of Verilator stops at the outer loop of
// row, line 29, with an "Unsupported" message, which does not count.

module test_illegal_generate_nested_same_genvar;
  genvar r, c;
  for (r = 0; r < 2; r = r + 1) begin : grid
    for (c = 0; c < 3; c = c + 1) begin : col
      localparam int CELL = r * 3 + c;
    end
  end
  for (r = 0; r < 2; r = r + 1) begin : row
    for (r = 0; r < 3; r = r + 1) begin : item   // illegal
    end
  end
endmodule
