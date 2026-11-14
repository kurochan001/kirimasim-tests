/*
:name: test_illegal_randc_member_in_packed_union
:description: only a member of an unpacked structure can have a random qualifier; a randc member of a packed union is an error (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member a of the packed union of the variable bad has the randc qualifier
:expected_stderr_regex: test_illegal_randc_member_in_packed_union\.sv:35:
*/
// IEEE 1800-2023 §7.3 (Syntax 7-2, footnote 20): a member may be declared with
// a random qualifier, rand or randc, only within an unpacked structure.
// The unpacked structure of the variable ok has the member a declared randc,
// which is legal, and the packed union of the variable okp has two 4-bit
// members without a qualifier. The legal design assigns the members of ok and
// the member a of okp, and prints ok.a, ok.b and okp.b, which shares the bits
// of okp.a: 6 11 9. The variable bad has the union of okp with its member a
// declared randc.
// Icarus Verilog 13.0 does not support random qualifiers on members and
// reports syntax errors on both randc declarations, which do not count.
// The 5.054 release of Verilator accepts the declaration of bad.

module test_illegal_randc_member_in_packed_union;
  struct { randc bit [3:0] a; bit [3:0] b; } ok;
  union packed { bit [3:0] a; bit [3:0] b; } okp;
  initial begin
    ok.a = 4'd6;
    ok.b = 4'd11;
    okp.a = 4'd9;
    $display("%0d %0d %0d", ok.a, ok.b, okp.b);
  end
  union packed { randc bit [3:0] a; bit [3:0] b; } bad;   // illegal: randc in a union
endmodule
