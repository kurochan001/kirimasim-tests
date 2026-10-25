/*
:name: test_illegal_void_member_in_struct
:description: a structure member cannot have the type void, which is legal only for members of tagged unions (IEEE 1800-2023 Section 7.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure of the variable bad has the void member none
:expected_stderr_regex: test_illegal_void_member_in_struct\.sv:30:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1, footnote 20): a structure or union member
// can be declared with void instead of a data type only within tagged unions,
// so never in a structure.
// The packed structure of the variable ok has two 4-bit members; the legal
// design assigns it and prints the members: a 5. The unpacked structure of the
// variable bad has a void member and an int member.
// Icarus Verilog 13.0 reports syntax errors on void members, and the 5.052
// release reports void as supported only for tagged unions; that is an error on
// the line, but about a construct it does not support, so it does not count.

module test_illegal_void_member_in_struct;
  struct packed { bit [3:0] hi; bit [3:0] lo; } ok;
  initial begin
    ok = 8'ha5;
    $display("%h %h", ok.hi, ok.lo);
  end
  struct { void none; int lo; } bad;   // illegal: void member in a struct
endmodule
