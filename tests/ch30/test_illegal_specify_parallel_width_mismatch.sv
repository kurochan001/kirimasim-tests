/*
:name: test_illegal_specify_parallel_width_mismatch
:description: A parallel connection path needs a source and a destination of the same number of bits (IEEE 1800-2023 Section 30.4.5)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a parallel connection joins the four-bit a to the two-bit y
:expected_stderr_regex: test_illegal_specify_parallel_width_mismatch\.sv:22:
*/
// IEEE 1800-2023 §30.4.5: a parallel connection (=>) joins each bit of the
// source to the corresponding bit of the destination, so both need the same
// number of bits; paths between vectors of different sizes need a full
// connection (*>). a has four bits and y two.

module sub(output [1:0] y, input [3:0] a);
  assign y = a[1:0];
  specify
    (a => y) = 2;      // illegal: 4 bits to 2 bits in parallel
  endspecify
endmodule

module test_illegal_specify_parallel_width_mismatch;
  reg [3:0] a = 0;
  wire [1:0] y;
  sub u(y, a);
endmodule
