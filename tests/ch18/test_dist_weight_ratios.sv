/*
:name: test_dist_weight_ratios
:description: A dist selects its items with probabilities proportional to their weights, := and :/ agree on a single value, a range weight counts every value of the range, overlapping items add, zero weights do not remove a value and weights are unsigned (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3 18.5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_weight_ratios.expected
*/
// IEEE 1800-2023 §18.5.3: absent other constraints, an item of a dist is
// chosen with probability proportional to its weight. The test calls
// randomize() 600 times for each of nine small classes and compares counts:
// - a and b use the weights 1:2:5 with := and :/, so 300 must be the most
//   frequent value and at least three times as frequent as 100;
// - c gives the range [0:2] the weight 3 with :=, so its three values
//   together are three times as likely as the value 3;
// - e names [0:2] and then 1 again, so the weights of 1 add to 4 against 1;
// - f uses inside, whose four values are equally likely;
// - g gives 0 the weight -2, which is unsigned 4294967294, so 1 never occurs;
// - i names 4 without a weight, which defaults to := 1, and 5 with 1, so the
//   two values are equally likely;
// - z names 0 with the total weight zero and again in [0:2] :/ 3, so the
//   zero weight does not exclude 0: all three values stay equally likely.
// Exact counts depend on the generator, so the test prints comparisons.

class dw_a;
  rand bit [9:0] v;
  constraint c { v dist {100 := 1, 200 := 2, 300 := 5}; }
endclass

class dw_b;
  rand bit [9:0] v;
  constraint c { v dist {100 :/ 1, 200 :/ 2, 300 :/ 5}; }
endclass

class dw_c;
  rand bit [3:0] v;
  constraint c { v dist {[0:2] := 1, 3 := 1}; }
endclass

class dw_e;
  rand bit [3:0] v;
  constraint c { v dist {[0:2] := 1, 1 := 3}; }
endclass

class dw_f;
  rand bit [3:0] v;
  constraint c { v inside {[0:3]}; }
endclass

class dw_i;
  rand bit [3:0] v;
  constraint c { v dist {4, 5 := 1}; }
endclass

class dw_g;
  rand bit v;
  int w = -2;
  constraint c { v dist {0 := w, 1 := 1}; }
endclass

class dw_z;
  rand bit [1:0] v;
  constraint c { v dist {0 := 0, [0:2] :/ 3}; }
endclass

module test_dist_weight_ratios;
  dw_a oa = new;
  dw_b ob = new;
  dw_c oc = new;
  dw_e oe = new;
  dw_f of = new;
  dw_g og = new;
  dw_i oi = new;
  dw_z oz = new;
  int a[3];
  int b[3];
  int c012, c3;
  int e0, e1, e2;
  int fv[4];
  int g1;
  int i4, i5, ioutside;
  int z[3];
  int zseen, zout;
  int outside;
  int failed = 0;

  initial begin
    i4 = 0;
    i5 = 0;
    ioutside = 0;
    zseen = 0;
    zout = 0;
    repeat (600) begin
      if (!oa.randomize()) failed++;
      case (oa.v)
        100: a[0]++;
        200: a[1]++;
        300: a[2]++;
        default: outside++;
      endcase
      if (!ob.randomize()) failed++;
      case (ob.v)
        100: b[0]++;
        200: b[1]++;
        300: b[2]++;
        default: outside++;
      endcase
      if (!oc.randomize()) failed++;
      if (oc.v <= 2) c012++; else if (oc.v == 3) c3++; else outside++;
      if (!oe.randomize()) failed++;
      case (oe.v)
        0: e0++;
        1: e1++;
        2: e2++;
        default: outside++;
      endcase
      if (!of.randomize()) failed++;
      if (of.v <= 3) fv[of.v]++; else outside++;
      if (!oi.randomize()) begin
        failed++;
      end else if (oi.v == 4) begin
        i4++;
      end else if (oi.v == 5) begin
        i5++;
      end else begin
        ioutside++;
      end
      if (!og.randomize()) begin
        failed++;
      end else if (og.v) begin
        g1++;
      end
      if (!oz.randomize()) begin
        failed++;
      end else if (oz.v <= 2) begin
        z[oz.v]++;
      end else begin
        zout++;
      end
    end
    $display("a: 1<2<5 ordered %0d, 300 at least 3 times 100 %0d",
             a[0] < a[1] && a[1] < a[2], a[2] > 3 * a[0]);
    $display("b: 1<2<5 ordered %0d, 300 at least 3 times 100 %0d",
             b[0] < b[1] && b[1] < b[2], b[2] > 3 * b[0]);
    $display("values outside the named items %0d", outside);
    $display("c: range 0..2 three times value 3 %0d", 3 * c3 < 2 * c012);
    $display("e: 1 more than 1.7 times 0 and 2 %0d", e1 * 10 > 17 * (e0 + e2));
    $display("f: four values each in 90..220 %0d, only 0..3 seen %0d",
             fv[0] >= 90 && fv[0] <= 220 && fv[1] >= 90 && fv[1] <= 220
             && fv[2] >= 90 && fv[2] <= 220 && fv[3] >= 90 && fv[3] <= 220,
             fv[0] + fv[1] + fv[2] + fv[3]);
    $display("g: value 1 of weight 1 seen %0d", g1);
    $display("i: 4 and 5 each in 240..360 %0d, other values %0d",
             i4 >= 240 && i4 <= 360 && i5 >= 240 && i5 <= 360, ioutside);
    foreach (z[i]) if (z[i] > 0) zseen++;
    $display("z: 0,1,2 each in 130..270 %0d, values seen %0d, other %0d",
             z[0] >= 130 && z[0] <= 270 && z[1] >= 130 && z[1] <= 270
             && z[2] >= 130 && z[2] <= 270, zseen, zout);
    $display("failed calls %0d", failed);
  end
endmodule
