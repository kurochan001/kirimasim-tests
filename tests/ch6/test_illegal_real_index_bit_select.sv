/*
:name: test_illegal_real_index_bit_select
:description: A bit-select of a vector cannot have a real index (IEEE 1800-2023 Section 6.12)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.12 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bit-select of the vector v has the real index r
:expected_stderr_regex: test_illegal_real_index_bit_select\.sv:21:
*/
// IEEE 1800-2023 §6.12: a real expression cannot be the index of a
// bit-select or part-select of a vector (11.5.1). v[r] selects a bit of v
// with the real variable r as its index, so it is illegal.

module test_illegal_real_index_bit_select;
  logic [7:0] v;
  real r = 1.0;
  initial v[r] = 1'b1;   // illegal: real index of a bit-select
endmodule
