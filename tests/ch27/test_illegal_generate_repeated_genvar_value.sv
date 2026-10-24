/*
:name: test_illegal_generate_repeated_genvar_value
:description: a loop generate scheme whose genvar takes the same value a second time is an error (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the genvar of loop ring goes 0, 3, 0, so its value 0 is repeated
:expected_stderr_regex: test_illegal_generate_repeated_genvar_value\.sv:23:
*/
// IEEE 1800-2023 §27.4: it is an error if a genvar value is repeated while
// the loop generate scheme is evaluated. In loop ring the iteration takes
// the genvar from 0 to 3 and back to 0, which the condition still accepts.
// Loop line, whose values 0, 3 do not repeat, is legal.

module test_illegal_generate_repeated_genvar_value;
  for (genvar i = 0; i < 6; i = i + 3) begin : line
    int v = i;
  end
  for (genvar i = 0; i < 6; i = (i + 3) % 6) begin : ring   // illegal
    int v = i;
  end
endmodule
