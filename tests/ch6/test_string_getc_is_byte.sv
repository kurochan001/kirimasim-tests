/*
:name: test_string_getc_is_byte
:description: str.getc(i) returns a byte, so a concatenation of two calls is 16 bits wide (IEEE 1800-2023 Section 6.16.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.3 11.4.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_getc_is_byte.expected
*/
// IEEE 1800-2023 §6.16.3: str.getc(i) returns the ASCII code of character i
// as a byte. A concatenation (11.4.12) of two calls is therefore 16 bits
// wide, and $bits of one call is 8. A byte is signed, so a character code of
// 128 or more reads as a negative number.

module test_string_getc_is_byte;
  string s = "AB";
  string hi = "\xe9";
  logic [15:0] cc;

  initial begin
    cc = {s.getc(0), s.getc(1)};
    $display("{s.getc(0), s.getc(1)} = %h, $bits = %0d", cc, $bits({s.getc(0), s.getc(1)}));
    $display("$bits(s.getc(0)) = %0d", $bits(s.getc(0)));
    $display("hi.getc(0) = %0d", hi.getc(0));
  end
endmodule
