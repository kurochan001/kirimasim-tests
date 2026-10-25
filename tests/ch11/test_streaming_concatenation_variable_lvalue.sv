/*
:name: test_streaming_concatenation_variable_lvalue
:description: A streaming concatenation with the >> operator is a variable lvalue of a blocking and of a nonblocking assignment; the stream fills the variables from the most significant part, so 12'hABC gives a, b and c the values A, B and C, and a later nonblocking assignment gives them 1, 2 and 3 (IEEE 1800-2023 Sections 11.4.14 and 11.4.14.3 and footnote 52 of A.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.4.14.3 A.8.1 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_streaming_concatenation_variable_lvalue.expected
*/
// IEEE 1800-2023 A.8.1: a streaming concatenation is a stream operator, an
// optional slice size and a stream concatenation of stream expressions.
// Footnote 52 of A.10: a streaming concatenation shall not be nested inside
// another variable lvalue, shall not be the target of an increment or
// decrement, and may be the target only of the simple assignment or the
// nonblocking assignment. §11.4.14 and §11.4.14.3: as an lvalue, the stream
// of the right-hand side is distributed over the variables in the order of
// the stream, so with >> the most significant slice goes to the first
// variable.
//
// {>>{a, b, c}} = 12'hABC gives a = A, b = B and c = C, and the nonblocking
// {>>{a, b, c}} <= 12'h123 gives them 1, 2 and 3 at the next time step.
//
// Icarus Verilog 13.0 does not support streaming concatenations on the left
// of an assignment; Verilator 5.052 produces this output.

`timescale 1ns/1ns

module test_streaming_concatenation_variable_lvalue;
  logic [3:0] a = 4'h1, b = 4'h2, c = 4'h3;

  initial begin
    {>>{a, b, c}} = 12'hABC;
    $display("right %h %h %h", a, b, c);
    {>>{a, b, c}} <= 12'h123;
    #1 $display("nba %h %h %h", a, b, c);
  end
endmodule
