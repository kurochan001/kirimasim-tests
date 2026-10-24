/*
:name: test_illegal_string_in_untagged_union
:description: a dynamic type such as string can be a member of a tagged union only, not of an untagged union (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the untagged union of the variable bad has the string member s
:expected_stderr_regex: test_illegal_string_in_untagged_union\.sv:31:
*/
// IEEE 1800-2023 §7.3: dynamic types and chandle types can be used only in
// tagged unions; §7.3.2 says again that they shall not be used in untagged
// unions. string is a dynamic type: its length changes at run time (6.16).
// The unpacked structure of the variable ok has a string member and an int
// member, which is legal; the legal design assigns them and prints them: abc 3.
// The untagged unpacked union of the variable bad has a string member and an
// int member.
// Icarus Verilog 13.0 reports unpacked structures and unions as not supported,
// which does not count. The 5.052 release accepts the declaration of bad.

module test_illegal_string_in_untagged_union;
  struct { string s; int i; } ok;
  initial begin
    ok.s = "abc";
    ok.i = ok.s.len();
    $display("%s %0d", ok.s, ok.i);
  end
  union { string s; int i; } bad;   // illegal: string in an untagged union
endmodule
