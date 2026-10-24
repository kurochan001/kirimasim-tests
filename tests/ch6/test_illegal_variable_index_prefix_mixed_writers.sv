/*
:name: test_illegal_variable_index_prefix_mixed_writers
:description: A procedural write through a variable index covers every element in its longest static prefix, so it conflicts with a continuous assignment to any of them even if the index never selects it (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.5 11.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the longest static prefix of v[i] is v, whose bit 0 also has a continuous assignment
:expected_stderr_regex: test_illegal_variable_index_prefix_mixed_writers\.sv:(26|27):
*/
// IEEE 1800-2023 §6.5: it is an error to have a mixture of procedural and
// continuous assignments to any term in the expansion of the longest static
// prefix of a variable. The index i of v[i] is a variable, so the longest
// static prefix of v[i] is the whole of v (11.5.3), and the procedural write
// counts for every bit of v, bit 0 included, which a continuous assignment
// also writes. That i is always 2 when the simulation runs does not matter.
// A tool can report either assignment.
// Oracle checks: the 5.052 release accepts the design.

module test_illegal_variable_index_prefix_mixed_writers;
  logic [3:0] v;
  int i = 2;
  assign v[0] = 1'b1;   // illegal: a continuous assignment to bit 0 of v
  initial v[i] = 1'b0;  // illegal: and a procedural one to the prefix v
endmodule
