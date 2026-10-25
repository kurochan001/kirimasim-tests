/*
:name: test_illegal_packed_tagged_union_real_member
:description: the members of a packed tagged union have to be of packed types, though their sizes may differ; a real member is an error (IEEE 1800-2023 Section 7.3.2)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed tagged union of the variable bad has the member r of type real, which is not a packed type
:expected_stderr_regex: test_illegal_packed_tagged_union_real_member\.sv:28:
*/
// IEEE 1800-2023 §7.3.2: the members of a tagged union declared packed shall
// have packed types, but they need not have the same size. The size of a packed
// tagged union is the number of tag bits needed to code the member names plus
// the size of the largest member.
// The packed tagged union type ok_t has an 8-bit, a 4-bit and a void member of
// different sizes, which is legal; with three members it has 2 tag bits, and
// the legal design prints its size, 10. The packed tagged union of the variable
// bad has a real member.
// Neither Icarus Verilog 13.0 nor the 5.052 release supports tagged unions; the
// errors they report on these declarations do not count.

module test_illegal_packed_tagged_union_real_member;
  typedef union tagged packed { bit [7:0] a; bit [3:0] b; void none; } ok_t;
  initial $display("%0d", $bits(ok_t));
  union tagged packed { bit [7:0] a; real r; } bad;   // illegal: real member
endmodule
