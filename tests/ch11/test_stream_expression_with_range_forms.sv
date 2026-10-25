/*
:name: test_stream_expression_with_range_forms
:description: A stream expression over an unpacked array streams the whole array without a with range, and only the selected elements with a with range of one index, of low:high, of base+:width or of base-:width, all computed from a variable, both when packing a fixed-size array and a queue and when unpacking into part of an array (IEEE 1800-2023 Section 11.4.14.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4 11.4.14 11.4.14.2 11.4.14.3 A.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_expression_with_range_forms.expected
*/
// IEEE 1800-2023 A.8.1: a stream expression is an expression with an optional
// with [array_range_expression], which is one expression, e1 : e2, e1 +: e2
// or e1 -: e2. §11.4.14.4: the expression before with is a one-dimensional
// unpacked array, and the range is evaluated just before the array is
// streamed. On the right-hand side it acts as an array slice: only the
// selected elements are streamed, in index order. As an unpack target, only
// the selected elements are written and the rest of the array keeps its
// values (§11.4.14.3 takes the bits from the left of the source).
//
// arr holds 11 22 33 44 55 66 at indexes 0 to 5 and k is 1:
//   {>> {arr}}                112233445566 (no with: all elements)
//   {>> {arr with [k]}}       22
//   {>> {arr with [k:k+2]}}   223344
//   {>> {arr with [k+1+:2]}}  3344   (elements 2 and 3)
//   {>> {arr with [k+3-:3]}}  334455 (elements 2 to 4)
//   {<< byte {arr with [k:k+2]}} 443322 (the same three bytes reversed)
//   the queue a1 b2 c3 with [0+:2] streams a1b2;
//   {>> {arr with [k+1:k+2]}} = 16'hAABB writes aa and bb into elements 2 and
//   3, and the other elements keep 11 22 55 66.
// Each target has exactly the width of its stream.
//
// Icarus Verilog 13.0 does not support streaming concatenations, and the
// 5.052 release of Verilator does not support a with range in a stream
// expression; the expected output follows §11.4.14.4 alone.

module test_stream_expression_with_range_forms;
  byte arr [0:5] = '{8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66};
  byte q [$] = '{8'hA1, 8'hB2, 8'hC3};
  int k = 1;
  logic [47:0] w0;
  logic [7:0] w1;
  logic [15:0] w2, wq;
  logic [23:0] w3, w4, w5;

  initial begin
    w0 = {>> {arr}};
    w1 = {>> {arr with [k]}};
    w3 = {>> {arr with [k:k+2]}};
    w2 = {>> {arr with [k+1+:2]}};
    w4 = {>> {arr with [k+3-:3]}};
    w5 = {<< byte {arr with [k:k+2]}};
    wq = {>> {q with [0+:2]}};
    $display("pack %h %h %h %h %h %h %h", w0, w1, w3, w2, w4, w5, wq);
    {>> {arr with [k+1:k+2]}} = 16'hAABB;
    $display("unpack %h %h %h %h %h %h", arr[0], arr[1], arr[2], arr[3], arr[4], arr[5]);
  end
endmodule
