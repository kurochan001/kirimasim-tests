/*
:name: test_illegal_clocking_drive_incompatible_rhs
:description: the right-hand side of a synchronous drive has to be assignment compatible with the type of the clocking signal, so an unpacked array cannot be driven to a packed vector (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.16 6.22.3 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unpacked array arr is driven to cb.y, whose signal is the packed vector y
:expected_stderr_regex: test_illegal_clocking_drive_incompatible_rhs\.sv:40:
*/
// IEEE 1800-2023 §14.16: the expression of a synchronous drive can be any
// expression that is assignment compatible with the type of the signal of the
// clockvar. y is a 64-bit packed vector. §6.22.3: types are assignment
// compatible when they are equivalent or an implicit conversion is defined
// between them; all integral types are, so the 8-bit value 8'hff and the
// 64-bit packed structure ps may be driven to y. §7.6: a fixed-size unpacked
// array is assignment compatible with other unpacked arrays that meet the
// conditions listed there, and no implicit conversion turns the unpacked
// array arr of two int elements, although it has 64 bits, into the vector y.
// Icarus Verilog 13.0 does not support clocking blocks; the syntax errors it
// reports do not count.

`timescale 1ns/1ns
module test_illegal_clocking_drive_incompatible_rhs;
  logic clk = 0;
  logic [63:0] y;
  int arr [2] = '{1, 2};
  struct packed { int hi; int lo; } ps = '{3, 4};
  default clocking cb @(posedge clk);
    output y;
  endclocking
  always #5 clk = ~clk;
  initial begin
    @(cb);
    cb.y <= 8'hff;
    cb.y <= ##1 ps;
    cb.y <= ##2 arr;   // illegal
  end
  initial #40 $finish;
endmodule
