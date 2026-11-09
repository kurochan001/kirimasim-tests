/*
:name: test_dist_tolerance_range_weights
:description: Integral tolerance ranges in dist items take := and :/ weights like other ranges, a value whose total weight is zero or that no item names is excluded, and tolerance ranges in inside constraints may have a random center or a negative tolerance (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3 11.4.13 18.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_tolerance_range_weights.expected
*/
// IEEE 1800-2023 §18.5.3: a dist item is a value range of 11.4.13, which
// includes [A +/- B] and [A +%- B]; an integral range may take := (the weight
// of each value) or :/ (the weight of the whole range). Weights of a value
// that several items name add up; a value whose total weight is zero, or that
// no item names, is excluded from the solutions. §11.4.13: [A +/- B] is
// [A - B : A + B] with the bounds put in order, and [A +%- B] uses A*B/100.0,
// truncated for an integral A. §18.5: the expressions of a constraint, also
// the center of a tolerance range, may be random variables.
// - x dist {[10 +/- 2] :/ 0, [10 +/- 1] := 1}: 8 to 12 get weight 0 from the
//   first item and 9 to 11 weight 1 each from the second, so x is 9, 10 or 11
//   (8 and 12 have total weight 0).
// - y dist {[100 +%- 10] := 0, 50 := 1}: the range is [90:110] with weight 0,
//   so y is always 50.
// - c == 20 and z inside {[c +/- 2]}: z is 18 to 22.
// - w inside {[40 +%- 25]}: the tolerance is 10, so w is 30 to 50.
// - u inside {[5 +/- -1]}: the bounds 6 and 4 are swapped, so u is 4 to 6.
// The test checks these sets in 30 calls and prints how many calls broke
// one: 0, then the fixed values of y and c.
// Icarus Verilog 13.0 does not support constraints, and the 5.052 release
// of Verilator does not support the tolerance ranges (with the same sets
// written as colon ranges it prints the expected lines).

class dtr_obj;
  rand int x, y, c, z, w, u;
  constraint c_x { x dist {[10 +/- 2] :/ 0, [10 +/- 1] := 1}; }
  constraint c_y { y dist {[100 +%- 10] := 0, 50 := 1}; }
  constraint c_z { c == 20; z inside {[c +/- 2]}; }
  constraint c_w { w inside {[40 +%- 25]}; u inside {[5 +/- -1]}; }
endclass

module test_dist_tolerance_range_weights;
  dtr_obj o;
  int bad;

  initial begin
    o = new;
    bad = 0;
    repeat (30) begin
      if (!o.randomize()) bad++;
      else if (!(o.x inside {[9:11]}) || o.y != 50 || o.c != 20 || !(o.z inside {[18:22]})
               || !(o.w inside {[30:50]}) || !(o.u inside {[4:6]}))
        bad++;
    end
    $display("tolerance sets: broken in %0d of 30 calls", bad);
    $display("y=%0d c=%0d", o.y, o.c);
  end
endmodule
