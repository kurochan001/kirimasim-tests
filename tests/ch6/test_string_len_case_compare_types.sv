/*
:name: test_string_len_case_compare_types
:description: len() returns int, toupper()/tolower() return a new string and leave the receiver unchanged, and compare()/icompare() take a string and return int (IEEE 1800-2023 Sections 6.16.1, 6.16.4-6.16.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.4 6.16.5 6.16.6 6.16.7 20.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_len_case_compare_types.expected
*/
// IEEE 1800-2023 §6.16.1: len() has no arguments and returns int, a signed
// 32-bit type, so the length of the empty string minus one is below zero.
// §6.16.4 and §6.16.5: toupper() and tolower() have no arguments, return a
// string, and leave the receiver as it was; characters that are not letters
// stay the same. §6.16.6 and §6.16.7: compare() and icompare() take one
// string argument and return int whose sign follows C strcmp (only the sign
// is printed, as strcmp fixes only the sign). The string literal "a\0b" given
// as the argument becomes the string "ab" (§6.16: a \0 character is removed
// when a literal is converted to string). $typename (§20.6.1) shows the type
// of each call without evaluating it.
// Icarus Verilog 13.0 rejects toupper() as the argument of $typename ("not a
// string method"), an unsupported construct.

module test_string_len_case_compare_types;
  string s = "MiXed 9z";
  string e;
  string ab = "ab";
  string up, lo;

  function automatic string sign(int r);
    return r < 0 ? "neg" : (r == 0 ? "zero" : "pos");
  endfunction

  initial begin
    $display("len: %s bits=%0d value=%0d empty=%0d empty-1<0=%0d",
             $typename(s.len()), $bits(s.len()), s.len(), e.len(), e.len() - 1 < 0);
    $display("types: %s %s %s %s", $typename(s.toupper()), $typename(s.tolower()),
             $typename(s.compare(ab)), $typename(s.icompare(ab)));
    $display("bits: %0d %0d", $bits(s.compare(ab)), $bits(s.icompare(ab)));
    up = s.toupper();
    $display("after toupper: up=\"%s\" s=\"%s\"", up, s);
    lo = s.tolower();
    $display("after tolower: lo=\"%s\" s=\"%s\"", lo, s);
    $display("lengths: %0d %0d %0d", s.len(), up.len(), lo.len());
    $display("compare: %s %s %s %s", sign(ab.compare("abc")), sign(ab.compare("aa")),
             sign(ab.compare("ab")), sign(ab.compare("AB")));
    $display("icompare: %s %s %s %s", sign(ab.icompare("ABC")), sign(ab.icompare("AA")),
             sign(ab.icompare("AB")), sign(up.icompare(lo)));
    $display("literal argument: compare=%s icompare=%s", sign(ab.compare("a\0b")),
             sign(ab.icompare("A\0B")));
  end
endmodule
