/*
:name: test_protect_encrypts_only_delimited_source_ranges
:description: Two protected bodies preserve surrounding source and emit separate encryption envelopes
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.3.1 34.5.1.2 34.5.2.2 34.5.5.2 34.5.6.2 34.5.7.2 34.5.9.2 34.5.11.2 34.5.15.2 34.5.30.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: encryption_fixture_top
:expected_stdout: protected values=17,29 clear=11
*/
`timescale 1ns/1ns
`pragma protect author = "Outer Author A"
`pragma protect author_info = "Outer Information A"
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64", line_length=48, bytes=1)

module encryption_fixture_clear(output wire [7:0] value);
  assign value = 8'd11;
endmodule

`pragma protect begin
  // Preserve the two leading spaces and this ordinary source comment.
`pragma protect author = "Inner Author A1"
`pragma protect author_info = "Inner Information A1"
`pragma protect comment = "Clear Note A1"
module encryption_fixture_first(output wire [7:0] value);
  assign value = 8'd17;
endmodule
`pragma protect end

// Ordinary source between the two protected bodies.
`pragma protect author = "Middle Author A"
`pragma protect begin
// Retain this comment with the second body.
`pragma protect author = "Inner Author A2"
`pragma protect author_info = "Inner Information A2"
`pragma protect comment = "Clear Note A2"
module encryption_fixture_second(output wire [7:0] value);
  assign value = 8'd29;
endmodule
`pragma protect end

module encryption_fixture_top;
  wire [7:0] first, second, clear;
  encryption_fixture_first a(first);
  encryption_fixture_second b(second);
  encryption_fixture_clear control(clear);
  initial #1 $display("protected values=%0d,%0d clear=%0d", first, second, clear);
endmodule
