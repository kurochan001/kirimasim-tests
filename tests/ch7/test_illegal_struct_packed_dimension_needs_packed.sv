/*
:name: test_illegal_struct_packed_dimension_needs_packed
:description: a packed dimension after a structure declaration needs the packed keyword; an unpacked structure with a packed dimension is an error (IEEE 1800-2023 Section 7.3)
:tags: ch7
:type: elaboration
:lrm: 1800-2023 7.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the structure type of the variable bad has the packed dimension [2:0] but no packed keyword
:expected_stderr_regex: test_illegal_struct_packed_dimension_needs_packed\.sv:33:
*/
// IEEE 1800-2023 §7.3 (Syntax 7-2, footnote 17): a struct or union declaration
// may be followed by packed dimensions, and a packed dimension used with the
// struct keyword needs the packed keyword as well.
// The variable ok has a packed structure of two 2-bit members with the packed
// dimension [2:0], 12 bits in all. The legal design assigns 12'hd36 to it and
// prints its size, the member hi of element 2 (the upper four bits, d) and
// the member lo of element 0 (the lower four bits, 6): 12 3 2. The variable
// bad has the same members and dimension, and its structure has no packed
// keyword.
// Icarus Verilog 13.0 reports the unpacked structure as not supported, which
// does not count. The 5.054 release of Verilator rejects the line because
// the unpacked structure type is given a packed dimension.

module test_illegal_struct_packed_dimension_needs_packed;
  struct packed { bit [1:0] hi; bit [1:0] lo; } [2:0] ok;
  initial begin
    ok = 12'hd36;
    $display("%0d %0d %0d", $bits(ok), ok[2].hi, ok[0].lo);
  end
  struct { bit [1:0] hi; bit [1:0] lo; } [2:0] bad;   // illegal: no packed keyword
endmodule
