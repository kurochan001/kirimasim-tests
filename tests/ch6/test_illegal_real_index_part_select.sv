/*
:name: test_illegal_real_index_part_select
:description: A part-select of a vector cannot have a real index (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the indexed part-select of the vector v has the real start index r
:expected_stderr_regex: test_illegal_real_index_part_select\.sv:21:
*/
// IEEE 1800-2023 §6.12: a real expression cannot be the index of a
// bit-select or part-select of a vector (11.5.1). v[r +: 2] is an indexed
// part-select of v whose start is the real variable r, so it is illegal.

module test_illegal_real_index_part_select;
  logic [7:0] v;
  real r = 2.0;
  initial v[r +: 2] = 2'b11;   // illegal: real index of a part-select
endmodule
