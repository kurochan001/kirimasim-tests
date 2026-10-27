/*
:name: test_ch6_extra_procedural_assign_mixed_writers
:description: A procedural assign statement counts as a procedural assignment, so it conflicts with a continuous assignment to the same variable (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 10.6.1 11.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: v is written by the procedural assign statement in the initial block and by a continuous assignment
:expected_stderr_regex: test_ch6_extra_procedural_assign_mixed_writers\.sv:(21|22):
*/
// IEEE 1800-2023 §6.5: for the writer-conflict rule, a procedural assign
// statement (§10.6.1) is a procedural assignment. The statement on the marked
// line writes v procedurally and the continuous assignment writes the same
// variable, so the design is illegal. A tool may report either writer.

module test_ch6_extra_procedural_assign_mixed_writers;
  logic v;
  initial assign v = 1'b0;   // illegal: a procedural assignment to v
  assign v = 1'b1;           // illegal: and a continuous one
endmodule
