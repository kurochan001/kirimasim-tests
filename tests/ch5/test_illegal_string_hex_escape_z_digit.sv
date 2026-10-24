/*
:name: test_illegal_string_hex_escape_z_digit
:description: A hexadecimal escape sequence in a string literal whose second digit is z is rejected (IEEE 1800-2023 Section 5.9.1)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the escape sequence \x4z in the string literal uses z as a hexadecimal digit
:expected_stderr_regex: test_illegal_string_hex_escape_z_digit\.sv:28:
*/
// IEEE 1800-2023 §5.9.1 (Table 5-1): \xdd gives a character from one or two
// hexadecimal digits, and it is illegal for a digit of the escape to be an x
// or z digit of Syntax 5-2; if only one digit is used, the next character
// shall not be a hexadecimal digit, which by Syntax 5-2 includes z as well.
// \x41 is legal ("A"); in \x4z on the marked line z is either a digit of
// the escape or the character right after a one-digit escape, and both are
// errors. Icarus Verilog 13.0 accepts the literal; Verilator 5.052 rejects
// every \x escape, also the legal one, so its error is not this rule.

module test_illegal_string_hex_escape_z_digit;
  string a, b;

  initial begin
    a = "\x41";
    b = "\x4z";   // illegal: z as a digit of a hexadecimal escape
    $display("%s %0d", a, b.len());
  end
endmodule
