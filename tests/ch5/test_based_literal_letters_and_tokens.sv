/*
:name: test_based_literal_letters_and_tokens
:description: The base letters, the s designator and the hexadecimal digits of a based literal are case insensitive, white space may precede the value and follow the size, the three tokens can come from macros, and each base takes its own digits (IEEE 1800-2023 Section 5.7.1)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 5.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_based_literal_letters_and_tokens.expected
*/
// IEEE 1800-2023 §5.7.1: a based literal is up to three tokens: an optional
// size, an apostrophe with a base letter, and the digits of the value. The
// base letter (d, h, o, b) and the s that marks a signed literal may be upper
// or lower case, and so may the hexadecimal digits a to f. White space may
// come before the value token, and the tokens may be given by macros. The
// value has only digits legal for the base (§5.7, Syntax 5-2): 0 and 1 for
// binary, 0 to 7 for octal, 0 to 9 and a to f for hexadecimal, and each base
// also takes x, z and ?.
// Line "letters" writes the value a5 in all eight base letters and prints
// each in hexadecimal; line "signed" prints 4-bit literals with s, S and no
// s in decimal, where only the signed ones are -1. Line "spaces" uses white
// space after the size and before the value, and line "macro" builds a
// literal from three macros, with its value and size. Line "digits" uses
// every digit of each base, and line "xz" an x, a z and a ? in each base.

`define LIT_SIZE 12
`define LIT_BASE 'h
`define LIT_VALUE 9c3

module test_based_literal_letters_and_tokens;
  initial begin
    $display("letters: %h %h %h %h %h %h %h %h", 8'ha5, 8'HA5, 8'o245, 8'O245,
             8'b10100101, 8'B10100101, 8'd165, 8'D165);
    $display("signed: %0d %0d %0d %0d %0d %0d", 4'shf, 4'ShF, 4'SHf, 4'hf, 4'sb1111, 4'Sd15);
    $display("hexcase: %0d %0d", 16'hAbCd == 16'haBcD, 16'hABCD == 16'habcd);
    $display("spaces: %h %h %0d", 8 'h a5, 8'b	1010_0101, $bits(8 'h a5));
    $display("macro: %h %0d", `LIT_SIZE `LIT_BASE `LIT_VALUE,
             $bits(`LIT_SIZE `LIT_BASE `LIT_VALUE));
    $display("digits: %b %o %h %h %0d", 2'b10, 24'o76543210, 40'h0123456789,
             24'habcdef == 24'hABCDEF, 'd9876543);
    $display("xz: %b %o %h", 6'b1x0z?1, 9'o7xz, 12'h?xz);
  end
endmodule
