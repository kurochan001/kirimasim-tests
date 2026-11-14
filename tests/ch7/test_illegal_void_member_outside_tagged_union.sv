/*
:name: test_illegal_void_member_outside_tagged_union
:description: only a tagged union can have a void member; a void member of an untagged union is an error (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the untagged union of the variable bad has the void member nothing
:expected_stderr_regex: test_illegal_void_member_outside_tagged_union\.sv:33:
*/
// IEEE 1800-2023 §7.3 (Syntax 7-2, footnote 20): a member of a structure or
// union may be declared void only within a tagged union.
// The variable ok has an untagged unpacked union of an int and a 32-bit
// member; the legal design writes the member count and reads it back: 12.
// The untagged union of the variable bad has the int member count and the
// void member nothing; with the tagged keyword it would be legal (§7.3.2),
// but the legal design does not use a tagged union, which neither simulator
// supports.
// Icarus Verilog 13.0 reports a syntax error on the void member, and the
// 5.054 release of Verilator reports the void member as not supported;
// neither supports void members even in a tagged union, so neither error
// counts.

module test_illegal_void_member_outside_tagged_union;
  union { int count; bit [31:0] word; } ok;
  initial begin
    ok.count = 12;
    $display("%0d", ok.count);
  end
  union { int count; void nothing; } bad;   // illegal: void member in an untagged union
endmodule
