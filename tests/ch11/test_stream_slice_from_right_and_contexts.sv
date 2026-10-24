/*
:name: test_stream_slice_from_right_and_contexts
:description: << cuts the stream into blocks from its right end and keeps a short last block as it is, and a streaming concatenation can be the source or the target of an assignment, the operand of a bit-stream cast and an item of another streaming concatenation (IEEE 1800-2023 Section 11.4.14.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.2 11.4.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_slice_from_right_and_contexts.expected
*/
// IEEE 1800-2023 §11.4.14.2: for <<, the stream is cut into blocks of the
// slice size starting from its rightmost bit, the block order is reversed and
// the bits inside a block keep their order; a leftmost block that is shorter
// keeps its length, without padding or truncation. {<<3{8'b1101_0110}} has
// the blocks 110, 010 and 11 (from the right), giving 8'b110_010_11 = cb;
// cutting from the left would give ae. {<<5{8'b1011_0011}} gives
// 8'b10011_101 = 9d, not 76. A short block padded to the slice size would
// make the stream longer than the 8-bit targets.
// §11.4.14: a streaming concatenation can be the source of an assignment,
// its target (a and b get 12 and 34), the operand of a bit-stream cast, whose
// result can then be used in an expression (3412 + 1), and an item of
// another streaming concatenation, which is packed as its own stream (21
// followed by 34).
// Icarus Verilog 13.0 does not support streaming concatenations.

module test_stream_slice_from_right_and_contexts;
  typedef bit [15:0] h_t;
  logic [7:0] r8a, r8b;
  logic [15:0] r16;
  logic [7:0] a, b;
  h_t h;

  initial begin
    r8a = {<<3{8'b1101_0110}};
    r8b = {<<5{8'b1011_0011}};
    $display("slices from the right: %h %h", r8a, r8b);
    r16 = {>>{8'hc5, 8'h3a}};
    $display("source: %h", r16);
    {>>{a, b}} = 16'h1234;
    $display("target: a=%h b=%h", a, b);
    h = h_t'({<<8{16'h1234}}) + 16'h1;
    $display("cast operand: %h", h);
    r16 = {>>{{<<4{8'h12}}, 8'h34}};
    $display("nested: %h", r16);
  end
endmodule
