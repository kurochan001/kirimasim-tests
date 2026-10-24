/*
:name: test_illegal_specify_parallel_vector_to_scalar
:description: A module path between a vector source and a scalar destination has to be a full connection; a parallel connection is illegal (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel connection (a => y) joins the four-bit vector a to the scalar y
:expected_stderr_regex: test_illegal_specify_parallel_vector_to_scalar\.sv:25:
*/
// IEEE 1800-2023 §30.4.5: a parallel connection (=>) joins each bit of the
// source to the corresponding bit of the destination, so source and
// destination need the same number of bits; a path between a vector and a
// scalar needs a full connection (*>). The path from the scalar b to the
// scalar y is a legal parallel connection; the one from the four-bit a to y
// is not.

module test_illegal_specify_parallel_vector_to_scalar_cell (output y, input [3:0] a, input b);
  assign y = (^a) & b;
  specify
    (b => y) = 1;
    (a => y) = 2;      // illegal: four bits to one bit in parallel
  endspecify
endmodule

module test_illegal_specify_parallel_vector_to_scalar;
  reg [3:0] a = 0;
  reg b = 0;
  wire y;

  test_illegal_specify_parallel_vector_to_scalar_cell c (y, a, b);
endmodule
