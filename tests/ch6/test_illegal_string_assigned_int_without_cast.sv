/*
:name: test_illegal_string_assigned_int_without_cast
:description: an integral value can be assigned to a string variable only with a cast (IEEE 1800-2023 Section 6.16)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the int variable k is assigned to the string variable s without a cast
:expected_stderr_regex: test_illegal_string_assigned_int_without_cast\.sv:33:
*/
// IEEE 1800-2023 §6.16: a string literal or an expression of string type can be
// assigned directly to a string variable, but values of integral type need a
// cast; a cast of an integral value to string gives a string of its bytes, the
// value zero-filled on the left to a multiple of 8 bits.
// The string s is assigned a string literal, the string t and the cast
// string'(k) of the int k, 32'h0000_4142, whose two zero bytes are dropped as 0
// characters are, and the byte c a string literal; the legal design prints
// them: hi hi AB A. The last statement assigns k to s without a cast.
// Icarus Verilog 13.0 and the 5.052 release accept the design. Icarus also
// keeps the two zero bytes in the string of string'(k), which 6.16 removes.

module test_illegal_string_assigned_int_without_cast;
  string s, t;
  int k = 32'h0000_4142;
  byte c = "A";
  initial begin
    s = "hi";
    t = s;
    $display("%s %s %s %s", s, t, string'(k), c);
    s = k;   // illegal: an integral value assigned to a string without a cast
  end
endmodule
