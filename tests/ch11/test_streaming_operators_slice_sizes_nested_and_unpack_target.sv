/*
:name: test_streaming_operators_slice_sizes_nested_and_unpack_target
:description: Streaming concatenations with each stream operator, without a slice size and with a slice size given by a simple type or a constant expression, with several stream expressions and nested, as the source of assignments and of a cast and as the target that unpacks a value (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.1 11.4.14.2 11.4.14.3 A.8.1 A.8.4 A.8.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_operators_slice_sizes_nested_and_unpack_target.expected
*/
// IEEE 1800-2023 A.8.1 and §11.4.14: a streaming concatenation is braces
// around >> or <<, an optional slice size (a simple type or a constant
// expression) and a stream concatenation: braces around one or more
// comma-separated stream expressions. A.8.4: it is a primary; A.8.5: it is
// also a variable lvalue.
// §11.4.14.1: the stream expressions are joined left to right. §11.4.14.2:
// >> keeps the order; << reverses the order of blocks of slice-size bits
// (1 bit by default, the size of the type for a type), cut from the right.
// §11.4.14.3: as an assignment target, it unpacks the stream, taking its
// bits from the left.
//
// j holds "ABCD" (41424344). The pack results have exactly the width of their
// targets, so no zero bits are appended:
//   {>> {j}} 41424344, {<< byte {j}} 44434241, {<< 16 {j}} 43444142;
//   {<< {8'b0011_0101}} 10101100 (bit reverse), {<< W {8'hA5}} with W = 4 is
//   5a, {<< 2 * W {16'h1234}} 3412, {>> {8'h12, 8'h34}} 1234, and the nested
//   {<< 2 {{<< {6'b110100}}}} 111000 (001011 cut into 11, 10, 00 from the
//   right and put in that order);
//   int'({<< byte {j}}) is the same 44434241 as a cast operand;
//   {>> {x, y}} = 16'hABCD gives x = ab and y = cd, and
//   {<< byte {x, y}} = 16'h1234 gives x = 34 and y = 12.
//
// Icarus Verilog 13.0 does not support streaming concatenations.

module test_streaming_operators_slice_sizes_nested_and_unpack_target;
  localparam int W = 4;
  int j = {"A", "B", "C", "D"};
  logic [31:0] p1, p2, p3;
  logic [7:0] p4, p5;
  logic [15:0] p6, p7;
  logic [5:0] p8;
  logic [7:0] x, y;
  int c;

  initial begin
    p1 = {>> {j}};
    p2 = {<< byte {j}};
    p3 = {<< 16 {j}};
    $display("ops %h %h %h", p1, p2, p3);
    p4 = {<< {8'b0011_0101}};
    p5 = {<< W {8'hA5}};
    p6 = {<< 2 * W {16'h1234}};
    p7 = {>> {8'h12, 8'h34}};
    p8 = {<< 2 {{<< {6'b110100}}}};
    $display("slices %b %h %h %h %b", p4, p5, p6, p7, p8);
    c = int'({<< byte {j}});
    $display("cast %h", c);
    {>> {x, y}} = 16'hABCD;
    $display("unpack %h %h", x, y);
    {<< byte {x, y}} = 16'h1234;
    $display("unpack %h %h", x, y);
  end
endmodule
