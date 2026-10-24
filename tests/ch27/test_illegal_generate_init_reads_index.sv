/*
:name: test_illegal_generate_init_reads_index
:description: the initialization of a loop generate cannot read the genvar it assigns (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initialization of loop again assigns genvar g from an expression that reads g
:expected_stderr_regex: test_illegal_generate_init_reads_index\.sv:23:
*/
// IEEE 1800-2023 §27.4: the initialization assignment of a loop generate
// scheme shall not reference the loop index on its right-hand side. Loop
// first initializes g from a constant; loop again, which reuses g after
// the first loop, initializes it from g + 1.

module test_illegal_generate_init_reads_index;
  genvar g;
  for (g = 0; g < 2; g = g + 1) begin : first
  end
  for (g = g + 1; g < 4; g = g + 1) begin : again   // illegal
  end
endmodule
