/*
:name: test_illegal_void_member_in_untagged_union
:description: a union member of type void is legal only in a tagged union (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the untagged union of the variable bad has the void member none
:expected_stderr_regex: test_illegal_void_member_in_untagged_union\.sv:29:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1, footnote 20): a structure or union member
// can be declared with void instead of a data type only within tagged unions.
// The packed union of the variable ok has two 8-bit members; the legal design
// writes one and reads the other: 5a. The untagged union of the variable bad
// has a void member.
// Icarus Verilog 13.0 reports syntax errors on void members, and the 5.052
// release reports void as supported only for tagged unions; that is an error on
// the line, but about a construct it does not support, so it does not count.

module test_illegal_void_member_in_untagged_union;
  union packed { bit [7:0] x; bit [7:0] y; } ok;
  initial begin
    ok.x = 8'h5a;
    $display("%h", ok.y);
  end
  union { void none; int i; } bad;   // illegal: void member in an untagged union
endmodule
