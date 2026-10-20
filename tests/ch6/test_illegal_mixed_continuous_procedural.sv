/*
:name: test_illegal_mixed_continuous_procedural
:description: A variable that a continuous assignment writes cannot also be written by a procedural assignment (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable v is written by a continuous assignment and by an initial procedure
:expected_stderr_regex: test_illegal_mixed_continuous_procedural\.sv:(21|22):
*/
// IEEE 1800-2023 §6.5: a variable that a continuous assignment writes cannot be
// written by any other continuous or procedural assignment to the same bits.
// Here v has a continuous and a procedural assignment, so the design is
// illegal; a tool can report either of them.

module test_illegal_mixed_continuous_procedural;
  logic v;
  assign v = 1'b1;     // illegal: a continuous assignment to v
  initial v = 1'b0;    // illegal: and a procedural one
endmodule
