/*
:name: test_sformat_format_expression_forms
:description: $sformat takes its format from its second argument, which may be a string literal, a string value, an integral value or an unpacked array of byte, and later arguments are values and not formats (IEEE 1800-2023 Section 21.3.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.2.1.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_format_expression_forms.expected
*/
// IEEE 1800-2023 §21.3.3: $sformat(dest, format, ...) interprets only its
// second argument as the format string; the format may be a string literal, a
// value of the string data type, an integral value that holds a character
// string, or an unpacked array of byte, and it accepts the format
// specifications of §21.2.1.1. The arguments after it are values for its
// specifications, not further format strings. The test formats five strings
// this way and prints each between brackets: "12-34" from a literal format,
// "a5/1010" from a string value, "n=7" from a packed vector, "9!" from an
// unpacked byte array, and "<%0d><ok>" from a literal format whose arguments
// are strings that would be formats if the later arguments were interpreted.

module test_sformat_format_expression_forms;
  string fmt = "%h/%b";
  string s, v;
  reg [8*5-1:0] ifmt = "n=%0d";
  byte bfmt[4];

  initial begin
    bfmt[0] = "%"; bfmt[1] = "0"; bfmt[2] = "d"; bfmt[3] = "!";
    $sformat(s, "%0d-%0d", 12, 34);
    $display("[%s]", s);
    $sformat(s, fmt, 8'hA5, 4'b1010);
    $display("[%s]", s);
    $sformat(s, ifmt, 7);
    $display("[%s]", s);
    $sformat(s, bfmt, 9);
    $display("[%s]", s);
    v = "%0d";
    $sformat(s, "<%s><%s>", v, "ok");
    $display("[%s]", s);
  end
endmodule
