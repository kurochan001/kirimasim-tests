/*
:name: test_inside_tolerance_center_type
:description: In [A +/- B] the tolerance B is cast to the type of A before the bounds are formed, so a narrow or signed A wraps a large B, a real B is truncated toward zero for an integral A, and an integral B keeps its value for a real A (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13 6.24.1 6.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_tolerance_center_type.expected
*/
// IEEE 1800-2023 §11.4.13: [A +/- B] is the range from A - type(A)'(B) to
// A + type(A)'(B), and [A +%- B] uses A*B/100.0 in place of B; the bounds are
// swapped when the first is larger, the range has the type of A, and a real
// tolerance converted to an integral type is truncated, not rounded.
// - A is the 4-bit unsigned a4 = 10 and B is 20: the cast to A's type keeps
//   the low 4 bits of 20, which are 4, so the range is [6:14] (not [-10:30]):
//   5 and 15 are outside, 6 and 14 inside.
// - A is the byte b8 = 10 and B is 200: as a byte 200 is -56, so the bounds
//   are 66 and -46, swapped to [-46:66]: -47 and 67 are outside.
// - A is the int 10 and B the real -2.9, truncated to -2 (rounding would give
//   -3): the range is [8:12], so 7 and 13 are outside.
// - B 0.5 is truncated to 0, so [10 +/- 0.5] holds only 10 (rounding would
//   give 1 and the range [9:11]).
// - A is the real 2.5 and B the int 1, converted to 1.0: the range is the
//   real [1.5:3.5]; 1.5 and 3.5 are inside, 3.6 is not, and the int 3 is
//   inside while 4 is not (the range is checked with <= and >=, and the int
//   is converted to real for those comparisons, §11.4.13 and §11.3.1).
// - [8.0 +%- -25.0] has the tolerance -2.0, so the bounds 10.0 and 6.0 are
//   swapped to [6.0:10.0]: 6.0 and 10.0 are inside, 5.9 is not.
// Icarus Verilog 13.0 does not support inside, and the 5.052 release
// of Verilator does not support the tolerance ranges.

module test_inside_tolerance_center_type;
  bit [3:0] a4 = 4'd10;
  byte b8 = 8'sd10;
  int v;
  real r;

  initial begin
    v = 5; $write("4-bit A, B 20: %b", v inside {[a4 +/- 20]});
    v = 6; $write(" %b", v inside {[a4 +/- 20]});
    v = 14; $write(" %b", v inside {[a4 +/- 20]});
    v = 15; $display(" %b", v inside {[a4 +/- 20]});
    v = -47; $write("byte A, B 200: %b", v inside {[b8 +/- 200]});
    v = -46; $write(" %b", v inside {[b8 +/- 200]});
    v = 66; $write(" %b", v inside {[b8 +/- 200]});
    v = 67; $display(" %b", v inside {[b8 +/- 200]});
    v = 7; $write("B -2.9: %b", v inside {[10 +/- -2.9]});
    v = 8; $write(" %b", v inside {[10 +/- -2.9]});
    v = 12; $write(" %b", v inside {[10 +/- -2.9]});
    v = 13; $display(" %b", v inside {[10 +/- -2.9]});
    v = 9; $write("B 0.5: %b", v inside {[10 +/- 0.5]});
    v = 10; $write(" %b", v inside {[10 +/- 0.5]});
    v = 11; $display(" %b", v inside {[10 +/- 0.5]});
    r = 1.5; $write("real A, int B: %b", r inside {[2.5 +/- 1]});
    r = 3.5; $write(" %b", r inside {[2.5 +/- 1]});
    r = 3.6; $write(" %b", r inside {[2.5 +/- 1]});
    v = 3; $write(" %b", v inside {[2.5 +/- 1]});
    v = 4; $display(" %b", v inside {[2.5 +/- 1]});
    r = 6.0; $write("real A, B -25 percent: %b", r inside {[8.0 +%- -25.0]});
    r = 10.0; $write(" %b", r inside {[8.0 +%- -25.0]});
    r = 5.9; $display(" %b", r inside {[8.0 +%- -25.0]});
  end
endmodule
