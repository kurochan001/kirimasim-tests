/*
:name: test_illegal_union_packed_dimension_needs_soft_or_packed
:description: a packed dimension after a union declaration needs the soft or the packed keyword; a union with neither and a packed dimension is an error (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the union type of the variable bad has the packed dimension [1:0] but neither the soft nor the packed keyword
:expected_stderr_regex: test_illegal_union_packed_dimension_needs_soft_or_packed\.sv:40:
*/
// IEEE 1800-2023 §7.3 (Syntax 7-2, footnote 17): a packed dimension used with
// the union keyword needs the soft keyword, the packed keyword or both.
// The variable okp has a hard packed union of two 4-bit members with the
// packed dimension [2:0], 12 bits in all; the legal design assigns 12'h7e1
// and prints its size, the member x of element 2 and the member y of element
// 0: 12 7 1. The variable oks has a soft union, which §7.3.1 makes packed
// without the packed keyword, of a 6-bit and a 3-bit member with the packed
// dimension [1:0]: each element has the size of its larger member, 6 bits,
// and the smaller member is right-justified. The design assigns 12'hb2d and
// prints the size, the member w of element 1 (the upper six bits) and the
// member n of element 0 (the lowest three bits): 12 44 5. The variable bad
// has a union of the members of okp and a packed dimension, without either
// keyword.
// Icarus Verilog 13.0 does not support soft or unpacked unions and reports
// errors on them, which do not count. The 5.054 release of Verilator rejects
// the line because the unpacked union type is given a packed dimension.

module test_illegal_union_packed_dimension_needs_soft_or_packed;
  union packed { bit [3:0] x; bit [3:0] y; } [2:0] okp;
  union soft { bit [5:0] w; bit [2:0] n; } [1:0] oks;
  initial begin
    okp = 12'h7e1;
    oks = 12'hb2d;
    $display("%0d %0d %0d", $bits(okp), okp[2].x, okp[0].y);
    $display("%0d %0d %0d", $bits(oks), oks[1].w, oks[0].n);
  end
  union { bit [3:0] x; bit [3:0] y; } [1:0] bad;   // illegal: neither soft nor packed
endmodule
