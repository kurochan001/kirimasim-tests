/*
:name: test_illegal_generate_loop_limit_variable
:description: The loop condition of a loop generate construct has to be a constant expression; a module variable used as the limit is not one, while a localparam is (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the condition of the second loop generate construct compares the genvar with the variable count
:expected_stderr_regex: test_illegal_generate_loop_limit_variable\.sv:28:
*/
// IEEE 1800-2023 §27.3: the loop control of a loop generate construct is part
// of its generate scheme, which is evaluated at elaboration, so its
// expressions shall be constant expressions. The first loop stops at the
// localparam N, which is legal. The second loop stops at the int variable
// count, which only has a value during simulation.
// The 5.052 release of Verilator stops on that line only with "Unsupported:
// Can't unroll generate for", which does not count as the diagnosis.

module test_illegal_generate_loop_limit_variable;
  localparam int N = 2;
  int count = 2;
  for (genvar i = 0; i < N; i++) begin : g_const
    int v = i;
  end
  for (genvar j = 0; j < count; j++) begin : g_var   // illegal: count is a variable
    int w = j;
  end
  initial $display("%0d", g_const[1].v);
endmodule
