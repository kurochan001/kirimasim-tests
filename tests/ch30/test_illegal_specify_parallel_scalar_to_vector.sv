/*
:name: test_illegal_specify_parallel_scalar_to_vector
:description: A module path between a scalar source and a vector destination has to be a full connection; a parallel connection is illegal (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel connection (s => q) joins the scalar s to the four-bit vector q
:expected_stderr_regex: test_illegal_specify_parallel_scalar_to_vector\.sv:25:
*/
// IEEE 1800-2023 §30.4.5: a parallel connection (=>) can only join a source
// and a destination with the same number of bits; a path between a scalar
// and a vector needs a full connection (*>). The path from the four-bit d to
// the four-bit q is a legal parallel connection; the one from the scalar s to
// q is not.

module test_illegal_specify_parallel_scalar_to_vector_cell (output [3:0] q, input [3:0] d,
                                                           input s);
  assign q = d & {4{s}};
  specify
    (d => q) = 1;
    (s => q) = 2;      // illegal: one bit to four bits in parallel
  endspecify
endmodule

module test_illegal_specify_parallel_scalar_to_vector;
  reg [3:0] d = 0;
  reg s = 0;
  wire [3:0] q;

  test_illegal_specify_parallel_scalar_to_vector_cell c (q, d, s);
endmodule
