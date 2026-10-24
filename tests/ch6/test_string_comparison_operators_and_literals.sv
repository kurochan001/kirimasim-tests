/*
:name: test_string_comparison_operators_and_literals
:description: The string equality and relational operators give 1 exactly when the condition holds in the lexicographic order of compare, a literal compared with a string is converted to a string first, and two literals compare as integral values (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16 6.16.8 11.4.5 11.4.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_comparison_operators_and_literals.expected
*/
// IEEE 1800-2023 §6.16, Table 6-9: for string operands, == gives 1 when the
// strings are equal and 0 when not, != is its negation, and <, <=, > and >=
// give 1 when the condition holds in the lexicographic order of the compare
// method (6.16.8), which compares character codes from the left and puts a
// prefix before the longer string. When one operand is a string and the other
// a string literal, the literal is converted to a string first; when both are
// literals the operators are the integral ones (11.4.4, 11.4.5).
// Each line shows ==, !=, <, <=, > and >= for one pair of string variables:
// smaller in the last character, larger, equal, a prefix, the empty string,
// and an upper-case letter, whose code is below the lower-case one.
// Then a literal is compared with a string variable and the same two values
// as two literals: "a\0b" with "ab" are equal as strings (the NUL character
// is removed when the literal becomes a string) but not as the integral
// values 24'h610062 and 16'h6162, and "b" is after "ab" as strings but
// 16'h0062 is below 16'h6162 as integral values.
// Oracle checks: Icarus Verilog 13.0 gives 1 for s_b < "ab" as well as for
// s_b > "ab"; by Table 6-9 "b" is after "ab", so s_b < "ab" is 0.

module test_string_comparison_operators_and_literals;
  string a, b;
  string s_ab = "ab";
  string s_b = "b";

  task automatic row(string x, string y);
    a = x;
    b = y;
    $display("\"%s\" vs \"%s\": == %0d != %0d < %0d <= %0d > %0d >= %0d", a, b,
             a == b, a != b, a < b, a <= b, a > b, a >= b);
  endtask

  initial begin
    row("abc", "abd");
    row("abd", "abc");
    row("abc", "abc");
    row("ab", "abc");
    row("", "a");
    row("B", "a");
    $display("string == literal: %0d, literals: %0d", s_ab == "a\0b", "ab" == "a\0b");
    $display("string != literal: %0d, literals: %0d", s_ab != "a\0b", "ab" != "a\0b");
    $display("string > literal: %0d, literals: %0d", s_b > "ab", "b" > "ab");
    $display("string < literal: %0d, literals: %0d", s_b < "ab", "b" < "ab");
    $display("literal <= string: %0d, literals: %0d", "ab" <= s_b, "ab" <= "b");
    $display("literal >= string: %0d, literals: %0d", "ab" >= s_b, "ab" >= "b");
  end
endmodule
