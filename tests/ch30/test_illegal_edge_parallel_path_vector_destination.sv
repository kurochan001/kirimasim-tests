/*
:name: test_illegal_edge_parallel_path_vector_destination
:description: The destination of a parallel edge-sensitive path has to be a scalar port or a bit-select, so an entire vector output is illegal there, while it is legal as the destination of a full edge-sensitive path (IEEE 1800-2023 Section 30.4.3)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parallel edge-sensitive path from c4 has the entire vector q as its destination
:expected_stderr_regex: test_illegal_edge_parallel_path_vector_destination\.sv:32:
*/
// IEEE 1800-2023 §30.4.3: for a parallel connection (=>) the destination of an
// edge-sensitive path shall be a scalar output or inout port or a bit-select
// of a vector one; for a full connection (*>) it can be a list of vector or
// scalar ports and their bit-selects or part-selects. The paths to the bit
// q[0] with => and to the vector r with *> are legal. The source c4 has the
// same width as q, so the parallel path to q breaks only the destination
// rule.
// Icarus Verilog 13.0 applies the path to the bit q[0] to the whole vector
// and reports a width mismatch there, which does not count; the 5.052 release
// of Verilator accepts the design.

module epv_cell(input wire clk, input wire [3:0] c4, input wire [3:0] d,
                output wire [3:0] q, output wire [3:0] r);
  assign q = d;
  assign r = d;
  specify
    (posedge clk => (q[0] : d[0])) = (2, 3);
    (posedge clk *> (r : d)) = (2, 3);
    (posedge c4 => (q : d)) = (4, 5);   // illegal: a vector destination with =>
  endspecify
endmodule

module test_illegal_edge_parallel_path_vector_destination;
  logic clk = 1'b0;
  logic [3:0] c4 = 4'h0, d = 4'h9;
  wire [3:0] q, r;
  epv_cell u (.clk(clk), .c4(c4), .d(d), .q(q), .r(r));
  initial #10 $display("%h %h", q, r);
endmodule
