/*
:name: test_protect_exports_author_fields_and_limits_encoded_lines
:description: Explicit encoding limits and author fields apply to each protected body
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.3.1 34.5.1.2 34.5.2.2 34.5.5.2 34.5.6.2 34.5.7.2 34.5.9.2 34.5.11.2 34.5.15.2 34.5.30.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: encryption_fixture_top
:expected_stdout: protected values=41,73 clear=31
*/
`timescale 1ns/1ns
`pragma protect author = "Outer Author B"
`pragma protect author_info = "Outer Information B"
`pragma protect data_method = "aes256-cbc"
`pragma protect encoding = (enctype="base64", line_length=24, bytes=2)

module encryption_fixture_clear(output wire [7:0] value);
  assign value = 8'd31;
endmodule

`pragma protect begin
// The metadata and comment have different values from the clear source.
`pragma protect author = "Inner Author B1"
`pragma protect author_info = "Inner Information B1"
`pragma protect comment = "Clear Note B1"
module encryption_fixture_first(output wire [7:0] value);
  // Keep both ordinary comments and the whitespace inside the body.

  assign value = 8'd41;
endmodule
`pragma protect end

// Change the line limit and the ignored byte count before the next body.
`pragma protect encoding = (enctype="base64", line_length=32, bytes=3)
`pragma protect author_info = "Middle Information B"
`pragma protect begin
  /* Leading whitespace in this body is part of the source. */
`pragma protect author = "Inner Author B2"
`pragma protect author_info = "Inner Information B2"
`pragma protect comment = "Clear Note B2"
`pragma protect runtime_license = (library="fixture", entry="check", feature="demo")
module encryption_fixture_second(output wire [7:0] value);
  assign value = 8'd73;
endmodule
`pragma protect end

module encryption_fixture_top;
  wire [7:0] first, second, clear;
  encryption_fixture_first a(first);
  encryption_fixture_second b(second);
  encryption_fixture_clear control(clear);
  initial #1 $display("protected values=%0d,%0d clear=%0d", first, second, clear);
endmodule
