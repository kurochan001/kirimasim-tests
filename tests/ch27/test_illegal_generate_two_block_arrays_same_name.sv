/*
:name: test_illegal_generate_two_block_arrays_same_name
:description: two loop generates in one scope cannot name their block arrays alike, even when their genvar values differ (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second loop generate names its block array stage, the name of the block array of the first loop
:expected_stderr_regex: test_illegal_generate_two_block_arrays_same_name\.sv:24:
*/
// IEEE 1800-2023 §27.4: the name of a generate block instance array cannot
// be the name of another generate block instance array of the same scope.
// The first loop makes stage[0] and stage[1], the second one would make
// stage[4] and stage[5]: although no index is used twice, the second name
// stage is an error. The third loop, named tail, is legal.

module test_illegal_generate_two_block_arrays_same_name;
  for (genvar s = 0; s < 2; s++) begin : stage
    int v = s;
  end
  for (genvar s = 4; s < 6; s++) begin : stage   // illegal
    int v = s;
  end
  for (genvar s = 4; s < 6; s++) begin : tail
    int v = s;
  end
endmodule
