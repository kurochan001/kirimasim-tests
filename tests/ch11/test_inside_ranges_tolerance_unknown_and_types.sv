/*
:name: test_inside_ranges_tolerance_unknown_and_types
:description: inside matches a colon range including its bounds, with $ as the lowest or highest value of the left operand's type, treats a reversed range as empty, accepts overlapping members, builds [A +/- B] in the type of A with a truncated tolerance and ordered bounds, compares nonintegral values with == and integral ones with ==?, and returns 1, 0 or x as the OR of the comparisons (IEEE 1800-2023 Section 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13 11.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_inside_ranges_tolerance_unknown_and_types.expected
*/
// IEEE 1800-2023 §11.4.13: x inside {set} is 1 when some member matches, 0
// when none does and no comparison is x, and x otherwise: the OR of all the
// comparisons. A singular left operand of any type is allowed (Table 11-1).
// Nonintegral values are compared with ==, integral ones with ==?, so x and
// z bits of a set member are wildcards and those of the left operand are
// not. [lo:hi] contains both bounds; $ stands for the lowest or highest value
// of the left operand's type; a range whose left bound is greater than the
// right one is empty. Members may repeat and overlap. [A +/- B] is the range
// from A - B to A + B with B converted to the type of A (a real B is
// truncated), the bounds swapped if needed, and the type of the range is the
// type of A.
// Each line prints a member that matches, one that does not and, where it
// applies, the bound itself. For the byte b, $ is -128 and 127. [10 +/- 2.9]
// is [8:12] (rounding would give [7:13]), [10 +/- -3] is [7:13], and the int
// 2 is not inside the real range [2.25:2.75].
// Icarus Verilog 13.0 does not support inside, and the tolerance ranges are
// not supported by Verilator 5.052.

class obj_c;
endclass

module test_inside_ranges_tolerance_unknown_and_types;
  int v;
  logic [7:0] u;
  byte b;
  real r;
  string s;
  obj_c h1 = new, h2 = new, h3 = new;
  int A = 10;

  initial begin
    v = 16; $write("colon range: %b", v inside {[16:23]});
    v = 23; $write(" %b", v inside {[16:23]});
    v = 15; $write(" %b", v inside {[16:23]});
    v = 24; $display(" %b", v inside {[16:23]});
    u = 0; $write("$ bounds: %b", u inside {[$:3]});
    u = 4; $write(" %b", u inside {[$:3]});
    u = 255; $write(" %b", u inside {[250:$]});
    b = -128; $write(" %b", b inside {[$:-100]});
    b = 127; $write(" %b", b inside {[100:$]});
    b = -99; $display(" %b", b inside {[$:-100]});
    v = 5; $write("reversed: %b", v inside {[7:3]});
    v = 7; $write(" %b", v inside {[7:3]});
    v = 5; $display(" %b", v inside {[7:3], 5});
    v = 5; $write("overlap: %b", v inside {[1:6], [4:9], 5, 5});
    v = 0; $display(" %b", v inside {[1:6], [4:9], 5, 5});
    v = 7; $write("+/-: %b", v inside {[A +/- 3]});
    v = 13; $write(" %b", v inside {[A +/- 3]});
    v = 6; $write(" %b", v inside {[A +/- 3]});
    v = 12; $write(" %b", v inside {[A +/- 2.9]});
    v = 13; $write(" %b", v inside {[A +/- 2.9]});
    v = 8; $display(" %b", v inside {[A +/- -3]});
    r = 2.3; $write("real A: %b", r inside {[2.5 +/- 0.25]});
    r = 2.8; $write(" %b", r inside {[2.5 +/- 0.25]});
    v = 2; $display(" %b", v inside {[2.5 +/- 0.25]});
    r = 1.5; $write("==: %b", r inside {1.5, 2.0});
    s = "ab"; $write(" %b", s inside {"ab", "cd"});
    s = "ef"; $write(" %b", s inside {"ab", "cd"});
    $display(" %b %b", h2 inside {h1, h2}, h3 inside {h1, h2});
    $display("==?: %b %b %b", 4'b1010 inside {4'b1z1x}, 4'b1010 inside {4'b0z1x, 4'b0000},
             4'b1z10 inside {4'b1010});
    $display("result: %b %b %b %b", 4'd3 inside {4'd1, 4'd2, 4'd3}, 4'd4 inside {4'd1, 4'd2},
             4'b1x10 inside {4'b1110, 4'b0000}, 4'b1x10 inside {4'b1110, 4'b1x10});
  end
endmodule
