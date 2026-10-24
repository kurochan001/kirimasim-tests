/*
:name: test_illegal_generate_iteration_other_genvar
:description: the iteration assignment of a loop generate has to assign the genvar that the initialization assigns (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: loop bad initializes genvar m but its iteration assigns genvar n
:expected_stderr_regex: test_illegal_generate_iteration_other_genvar\.sv:22:
*/
// IEEE 1800-2023 §27.4: the initialization and the iteration assignment of
// a loop generate scheme shall assign the same genvar. Loop ok initializes
// and updates m; loop bad initializes m and updates n instead.

module test_illegal_generate_iteration_other_genvar;
  genvar m, n;
  for (m = 0; m < 2; m = m + 1) begin : ok
  end
  for (m = 0; m < 2; n = m + 1) begin : bad   // illegal
  end
endmodule
