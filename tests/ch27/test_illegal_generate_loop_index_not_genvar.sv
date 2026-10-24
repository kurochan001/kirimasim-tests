/*
:name: test_illegal_generate_loop_index_not_genvar
:description: the index of a loop generate has to be declared as a genvar, before the loop or in its header (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the index k of loop bad is an int variable, not a genvar
:expected_stderr_regex: test_illegal_generate_loop_index_not_genvar\.sv:26:
*/
// IEEE 1800-2023 §27.4: the loop index of a loop generate shall be declared
// as a genvar before the loop uses it; Syntax 27-1 also lets the loop header
// declare it. Loops a and b use these two forms; loop bad uses the int
// variable k as its index.

module test_illegal_generate_loop_index_not_genvar;
  genvar g;
  int k;
  for (g = 0; g < 2; g = g + 1) begin : a
  end
  for (genvar h = 0; h < 2; h = h + 1) begin : b
  end
  for (k = 0; k < 2; k = k + 1) begin : bad   // illegal
  end
endmodule
