/*
:name: test_illegal_generate_region_in_loop_block
:description: a generate region may only be a direct item of a module, interface, program or checker body, so generate ... endgenerate inside a loop generate block is illegal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a generate region is written directly inside the block of the loop generate construct g, which is not a direct item of the module
:expected_stderr_regex: test_illegal_generate_region_in_loop_block\.sv:33:
*/
// IEEE 1800-2023 §27.3: an explicit generate region (generate ...
// endgenerate) may occur only directly as an item of a module, interface,
// program or checker, so it cannot be inside a generate block. The
// module has a region at its own level around the loop generate construct
// h, which is legal. The loop generate construct g is outside any region,
// and its block contains a region: that is the only error.
// test_illegal_generate_region_in_conditional_block covers the block of a
// conditional generate construct and test_illegal_generate_region_in_package
// a package.
// The design is accepted by Icarus Verilog 13.0.

module test_illegal_generate_region_in_loop_block;
  generate
    for (genvar i = 0; i < 2; i++) begin : h
      int a = i;
    end
  endgenerate

  for (genvar j = 0; j < 2; j++) begin : g
    generate   // illegal
      int b = j;
    endgenerate
  end

  initial $display("%0d", h[1].a);
endmodule
