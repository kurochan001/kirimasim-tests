/*
:name: test_string_ignores_null_characters
:description: A string variable drops the null characters of a string literal and ignores a null character written to one of its characters (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ignores_null_characters.expected
*/
// IEEE 1800-2023 §6.16: a string variable never contains the character "\0".
// When a string literal is assigned to it, the "\0" characters of the
// literal are left out, so "Hello\0World" gives a string of 10 characters.
// Writing 0 to one character of a string is ignored, while writing another
// character replaces that character.

module test_string_ignores_null_characters;
  string s = "Hello\0World";
  string t;

  initial begin
    t = "a\0b\0c";
    $display("s: len=%0d \"%s\"", s.len(), s);
    $display("t: len=%0d \"%s\"", t.len(), t);
    s[1] = "\0";
    $display("after s[1] = \"\\0\": len=%0d \"%s\"", s.len(), s);
    s[1] = "a";
    $display("after s[1] = \"a\": len=%0d \"%s\"", s.len(), s);
  end
endmodule
