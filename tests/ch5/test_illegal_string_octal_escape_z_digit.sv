/*
:name: test_illegal_string_octal_escape_z_digit
:description: An octal escape sequence in a string literal whose second digit is z is rejected (IEEE 1800-2023 Section 5.9.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the escape sequence \1z in the string literal uses z as an octal digit
:expected_stderr_regex: test_illegal_string_octal_escape_z_digit\.sv:27:
*/
// IEEE 1800-2023 §5.9.1 (Table 5-1): \ddd gives a character from one to
// three octal digits, and it is illegal for a digit of the escape to be an x
// or z digit of Syntax 5-2; if fewer than three digits are used, the next
// character shall not be an octal digit, which by Syntax 5-2 includes z as
// well. \101 is legal ("A"); in \1z on the marked line z is either a
// digit of the escape or the character right after a shorter escape, and
// both are errors. Icarus Verilog 13.0 and Verilator 5.052 accept it.

module test_illegal_string_octal_escape_z_digit;
  string a, b;

  initial begin
    a = "\101";
    b = "\1z";   // illegal: z as a digit of an octal escape
    $display("%s %0d", a, b.len());
  end
endmodule
