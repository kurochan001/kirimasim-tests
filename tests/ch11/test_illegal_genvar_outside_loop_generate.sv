/*
:name: test_illegal_genvar_outside_loop_generate
:description: a genvar can be a constant primary only within a loop generate construct (IEEE 1800-2023 Section 11.11)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the genvar g is used in the value of the local parameter OUT, outside the loop generate construct
:expected_stderr_regex: test_illegal_genvar_outside_loop_generate\.sv:26:
*/
// IEEE 1800-2023 §11.11 (Syntax 11-7, footnote 44): a genvar identifier shall
// be legal in a constant primary only within a loop generate construct. The
// local parameter Q inside the loop over g, and the index in L[1].Q, are
// legal; the local parameter OUT of the module uses g outside the loop.

module test_illegal_genvar_outside_loop_generate;
  genvar g;

  for (g = 0; g < 2; g++) begin : L
    localparam int Q = g * 3;
  end

  localparam int OUT = g + 1;   // illegal: a genvar outside a loop generate

  initial $display("%0d", L[1].Q);
endmodule
