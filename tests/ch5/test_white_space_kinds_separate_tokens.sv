/*
:name: test_white_space_kinds_separate_tokens
:description: Each kind of white space, a space, a tab, a newline, a formfeed and the end of a file, separates two tokens that would otherwise form one, so a & &b is a bitwise AND with a reduction AND and not a logical AND (IEEE 1800-2023 Section 5.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.3 A.9.4 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: ws_eof_first.sv ws_eof_second.sv
:expected_stdout: @test_white_space_kinds_separate_tokens.expected
*/
// IEEE 1800-2023 §5.3 and the white_space production of A.9.4: white space is
// a space, a tab, a newline, a formfeed or the end of a file (footnote 56 of
// A.10 marks the end of file), and it separates tokens. Two & characters with
// nothing between them are the one token && (logical AND); with white space
// between them they are two tokens, the binary & and a unary reduction &.
// With a = 4'b0110 and b = 4'b1111, a&&b is 1'b1, while a & (&b) is
// 4'b0110 & 4'b0001 = 4'b0000. Each display below separates the two &
// characters with one kind of white space only: a space, a tab, a newline and
// a formfeed (the source holds a real tab and formfeed character there).
// A tab and a formfeed also separate the keyword logic, the packed dimension,
// the identifier c, = and the literal in the declaration of c.
// The end of a file: the two files that :files: names, and this file, end
// right after endmodule with no newline. The second of those files starts
// with module, so the end of the first file is the only thing that keeps
// endmodule and module apart. The test prints a value from each of them.

module test_white_space_kinds_separate_tokens;
  logic [3:0] a = 4'b0110, b = 4'b1111;
  logic	[7:0]c	=8'h5A;
  ws_eof_first first ();
  ws_eof_second second ();

  initial begin
    #1;
    $display("none:     %b", a&&b);
    $display("space:    %b", a& &b);
    $display("tab:      %b", a&	&b);
    $display("newline:  %b", a&
&b);
    $display("formfeed: %b", a&&b);
    $display("c=%h", c);
    $display("first=%0d second=%0d", first.val, second.val);
  end
endmodule