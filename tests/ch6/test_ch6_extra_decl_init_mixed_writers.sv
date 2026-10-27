/*
:name: test_ch6_extra_decl_init_mixed_writers
:description: A variable initialization in its declaration counts as a procedural assignment, so it conflicts with a continuous assignment to the same variable (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 11.5.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: v is initialized in its declaration and also written by a continuous assignment
:expected_stderr_regex: test_ch6_extra_decl_init_mixed_writers\.sv:(23|24):
*/
// IEEE 1800-2023 §6.5: for the rule that forbids several continuous
// assignments or a mixture of procedural and continuous assignments to the
// expansion of the longest static prefix of a variable, a declared variable
// initialization is considered a procedural assignment. The initialization of
// v on the marked line is such an assignment, and the continuous assignment to
// v writes the same prefix, so the design is illegal. A tool may report either
// writer.

module test_ch6_extra_decl_init_mixed_writers;
  logic v = 1'b0;     // illegal: a procedural assignment to v
  assign v = 1'b1;    // illegal: and a continuous one
endmodule
