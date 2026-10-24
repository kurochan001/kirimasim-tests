/*
:name: test_illegal_unpacked_struct_packed_dimension
:description: a structure followed by a packed dimension has to be declared packed (IEEE 1800-2023 Sections 7.2, 6.8)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.2 6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure of the variable bad has the packed dimension [1:0] but no packed keyword
:expected_stderr_regex: test_illegal_unpacked_struct_packed_dimension\.sv:30:
*/
// IEEE 1800-2023 §7.2 (Syntax 7-1, footnote 17) and §6.8 (Syntax 6-3, footnote
// 17): when a packed dimension follows a struct declaration, the packed keyword
// shall be used as well.
// The variable okp has a packed structure of 4 bits with the packed dimension
// [1:0], 8 bits in all, and the legal design prints its size and the member a
// of its element 1 (the upper half): 8 a. The variable bad has the same
// structure and dimension without the packed keyword.
// Icarus Verilog 13.0 reports the unpacked structure as not supported, which
// does not count. The 5.052 release accepts the declaration of bad.

module test_illegal_unpacked_struct_packed_dimension;
  struct packed { bit [3:0] a; } [1:0] okp;
  initial begin
    okp = 8'ha5;
    $display("%0d %h", $bits(okp), okp[1].a);
  end
  struct { bit [3:0] a; } [1:0] bad;   // illegal: packed dimension without packed
endmodule
