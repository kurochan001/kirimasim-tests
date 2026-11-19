/*
:name: test_illegal_generate_region_in_conditional_block
:description: a generate region may only be a direct item of a module, interface, program or checker body, so generate ... endgenerate inside the block of a conditional generate construct is illegal (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a generate region is written directly inside the block of the conditional generate construct g, which is not a direct item of the module
:expected_stderr_regex: test_illegal_generate_region_in_conditional_block\.sv:36:
*/
// IEEE 1800-2023 §27.3: an explicit generate region (generate ...
// endgenerate) may occur only directly as an item of a module, interface,
// program or checker, so it cannot be inside a generate block. The
// module has a region at its own level around the case generate
// construct of the block h, which is legal. The if generate construct g
// is outside any region, and its block contains a region: that is the
// only error. test_illegal_generate_region_in_loop_block covers the block
// of a loop generate construct and test_illegal_generate_region_in_package
// a package.
// The design is accepted by Icarus Verilog 13.0.

module test_illegal_generate_region_in_conditional_block;
  localparam int P = 1;
  generate
    case (P)
      1: begin : h
        int a = 7;
      end
    endcase
  endgenerate

  if (P == 1) begin : g
    generate   // illegal
      int b = 8;
    endgenerate
  end

  initial $display("%0d", h.a);
endmodule
