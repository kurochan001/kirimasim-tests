/*
:name: test_illegal_scope_duplicate_in_unselected_generate
:description: The rule that a name declares one item per scope also holds inside a generate block that is not instantiated, apart from the shared names of the alternative blocks of one conditional generate construct (IEEE 1800-2023 Section 23.9)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.9 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate block off, which is not selected, declares two variables named v
:expected_stderr_regex: test_illegal_scope_duplicate_in_unselected_generate\.sv:29:
*/
// IEEE 1800-2023 §23.9: an identifier declares only one item within a scope,
// and for generate blocks this holds whether or not the block is
// instantiated. The exception is the alternative blocks of one conditional
// generate construct, which can share a name (27.5): the two blocks named sel
// below are legal. The block off is never selected, since its condition is
// 0, and it declares v twice.

module test_illegal_scope_duplicate_in_unselected_generate #(parameter int P = 1);
  if (P == 1) begin : sel
    int w = 1;
  end else begin : sel
    int w = 2;
  end
  if (P == 0) begin : off
    int v;
    int v;   // illegal: second v in the block off
  end
endmodule
