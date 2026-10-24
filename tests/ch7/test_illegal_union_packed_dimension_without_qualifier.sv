/*
:name: test_illegal_union_packed_dimension_without_qualifier
:description: a union followed by a packed dimension has to be declared packed or soft (IEEE 1800-2023 Sections 7.2, 6.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the union of the variable bad has the packed dimension [1:0] but neither the packed nor the soft keyword
:expected_stderr_regex: test_illegal_union_packed_dimension_without_qualifier\.sv:31:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1, footnote 17): when a packed dimension
// follows a union declaration, the soft or the packed keyword, or both, shall
// be used as well. §6.8 (Syntax 6-3, footnote 17) asks for the packed keyword
// with a packed dimension after struct or union.
// The variable okp has a packed union of two 4-bit members with the packed
// dimension [1:0], 8 bits in all; the legal design prints its size, the member
// a of element 1 and the member b of element 0: 8 3 c. The variable bad has the
// same union and dimension without either keyword.
// Icarus Verilog 13.0 reports the unpacked union as not supported, which does
// not count. The 5.052 release accepts the declaration of bad.

module test_illegal_union_packed_dimension_without_qualifier;
  union packed { bit [3:0] a; bit [3:0] b; } [1:0] okp;
  initial begin
    okp = 8'h3c;
    $display("%0d %h %h", $bits(okp), okp[1].a, okp[0].b);
  end
  union { bit [3:0] a; bit [3:0] b; } [1:0] bad;   // illegal: no packed or soft
endmodule
