/*
:name: test_illegal_generate_path_select_not_constant
:description: An instance select of a loop generate block in a hierarchical name has to be a constant expression, so it cannot be a variable (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.6 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hierarchical name g[k].v selects an iteration of the loop generate block g with the variable k, which is not a constant expression
:expected_stderr_regex: test_illegal_generate_path_select_not_constant\.sv:25:
*/
// IEEE 1800-2023 §23.6: the instance select that follows the name of an
// instance array or loop generate block (§27.4) in a hierarchical name is
// a constant expression. k is a variable, so g[k].v is not a legal
// hierarchical name; g[1].v would be.

module test_illegal_generate_path_select_not_constant;
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] v = i;
  end

  int k = 1;
  initial #1 $display("v=%h", g[k].v);   // illegal
endmodule
