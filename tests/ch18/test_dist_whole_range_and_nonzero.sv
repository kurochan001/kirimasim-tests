/*
:name: test_dist_whole_range_and_nonzero
:description: A := range weight counts every value of the range and a :/ range weight is the weight of the whole range, both even when another constraint removes values, and nonzero weights neither shrink the solution space nor make a solvable call fail (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_whole_range_and_nonzero.expected
*/
// IEEE 1800-2023 §18.5.3: the weight of an integral range with := is the
// number of all its values times the specified weight, and the weight of a
// range with :/ is the specified weight for the whole range. In both cases
// the weight applies to the range as a whole even when other constraints
// exclude some of its values. In dwr the range [0:3] := 1 has the weight 4
// although v >= 3 removes 0, 1 and 2, so 3 has weight 4 against 1 for 4; if
// the weight counted only the remaining values it would be 1 against 1. In
// dws the range [0:3] :/ 1 has the weight 1 although v >= 2 removes 0 and 1,
// so 2 and 3 together have weight 1 against 1 for 4; if the weight were
// split over the four values before the exclusion, they would have 1/2
// against 1.
// A nonzero weight neither removes a value from the solution space nor lets
// a solvable problem fail: dwq keeps every value below 3 and excludes only
// the value 3 that the distribution does not name, and dwk gives the hard
// v == 0 precedence over the weight 100 of the value 1 without failing.
// In Verilator 5.052 the dwr and dws calls are unsatisfiable and the dwk
// call fails when the hard v == 0 meets the weight 100; the clause decides.

class dwr_obj;
  rand bit [3:0] v;
  constraint c { v >= 3; v <= 4; v dist {[0:3] := 1, 4 := 1}; }
endclass

class dws_obj;
  rand bit [3:0] v;
  constraint c { v >= 2; v <= 4; v dist {[0:3] :/ 1, 4 := 1}; }
endclass

class dwq_obj;
  rand bit [1:0] v;
  constraint c { v < 3; v dist {0 := 1, 1 := 2, 2 := 3}; }
endclass

class dwk_obj;
  rand bit [1:0] v;
  constraint c { v == 0; v dist {0 := 1, 1 := 100}; }
endclass

module test_dist_whole_range_and_nonzero;
  dwr_obj orr = new;
  dws_obj osl = new;
  dwq_obj oq = new;
  dwk_obj ok = new;
  int n3, n4, rfail;
  int nr, ns4, sfail;
  int q[4];
  int qfail, qseen, qout;
  int kfail, kbad;

  initial begin
    n3 = 0;
    n4 = 0;
    rfail = 0;
    repeat (600) begin
      if (!orr.randomize()) rfail++;
      else if (orr.v == 3) n3++;
      else if (orr.v == 4) n4++;
    end
    $display("range :=: failed %0d, 3 in 440..520 %0d, 4 in 80..160 %0d",
             rfail, n3 >= 440 && n3 <= 520, n4 >= 80 && n4 <= 160);
    nr = 0;
    ns4 = 0;
    sfail = 0;
    repeat (600) begin
      if (!osl.randomize()) sfail++;
      else if (osl.v == 2 || osl.v == 3) nr++;
      else if (osl.v == 4) ns4++;
    end
    $display("range :/: failed %0d, 2,3 in 250..350 %0d, 4 in 250..350 %0d",
             sfail, nr >= 250 && nr <= 350, ns4 >= 250 && ns4 <= 350);
    foreach (q[i]) q[i] = 0;
    qfail = 0;
    qout = 0;
    repeat (300) begin
      if (!oq.randomize()) qfail++;
      else if (oq.v <= 2) q[oq.v]++;
      else qout++;
    end
    qseen = 0;
    foreach (q[i]) if (i < 3 && q[i] > 0) qseen++;
    $display("solution space: failed %0d, values seen %0d, value 3 seen %0d",
             qfail, qseen, qout);
    kfail = 0;
    kbad = 0;
    repeat (200) begin
      if (!ok.randomize()) kfail++;
      else if (ok.v != 0) kbad++;
    end
    $display("hard constraint: failed %0d, value not 0 %0d", kfail, kbad);
  end
endmodule
