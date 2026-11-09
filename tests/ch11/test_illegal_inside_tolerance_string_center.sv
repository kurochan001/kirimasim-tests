/*
:name: test_illegal_inside_tolerance_string_center
:description: A tolerance range is defined by subtracting the tolerance from its center and adding it, so a center of type string, which has no arithmetic operators, is an error, although a colon range of strings is legal (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.4.13 11.3 6.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the tolerance range [c +/- 1] has the string variable c as its center, and the subtraction and addition that define it are not defined for strings
:expected_stderr_regex: test_illegal_inside_tolerance_string_center\.sv:37:
*/
// IEEE 1800-2023 §11.4.13: [A +/- B] stands for the range from
// A - type(A)'(B) to A + type(A)'(B), in the type of A, and a colon range
// needs bounds of a type with <= and >=. §6.16 (Table 6-9) gives the string
// type comparison operators, so ["cat":"eel"] is a legal range, but neither
// §6.16 nor Table 11-1 (§11.3, where binary + and - take integral and real
// operands) gives strings an addition or a subtraction. With the string
// variable c as A, the bounds c - string'(1) and c + string'(1) cannot be
// formed, so the range is an error. The int tolerance range in r2 is legal.
// The standard has no example of a non-arithmetic center; the error follows
// from the definition of the range.
// Icarus Verilog 13.0 does not support inside, and the 5.052 release
// of Verilator does not support the tolerance ranges, so the errors
// they report on the marked line do not count.

module test_illegal_inside_tolerance_string_center;
  string s = "dog";
  string c = "dog";
  int v = 9;
  bit r1, r2, r3;

  initial begin
    r1 = s inside {["cat":"eel"]};
    r2 = v inside {[10 +/- 2]};
    r3 = s inside {[c +/- 1]};   // illegal: a string center has no - or +
    $display("%b %b", r1, r2);
  end
endmodule
