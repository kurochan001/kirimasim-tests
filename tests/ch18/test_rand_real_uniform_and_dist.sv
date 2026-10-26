/*
:name: test_rand_real_uniform_and_dist
:description: A rand real variable is uniformly distributed over its allowed range, and a dist for a real variable may name a single real value with :=, mix integral and real items and give a real tolerance range its weight with :/ (IEEE 1800-2023 Sections 18.4.1 and 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.1 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_real_uniform_and_dist.expected
*/
// IEEE 1800-2023 §18.4.1: random real values are uniformly distributed over
// their range, so r < 0.5 and r >= 0.5 each get about half of 1600 results;
// the bounds 720 and 880 are four standard deviations from 800, so a
// generator that makes one half more than about 56% of the values fails.
// §18.5.3: a dist for a real variable may mix integral and real items and may
// use := with a single real value; a real range and a real tolerance range
// need :/ and a weight. In v dist {0 := 5, 1.5 := 1, [2.0:2.5] :/ 1} the
// values outside the three items are excluded, and 0 is expected five times
// as often as 1.5 or the range. In t dist {0 := 1, [1.0+%-10.0] :/ 1} the
// integral 0 and the tolerance range 0.9 to 1.1 each have the total weight
// 1, so each gets about half of 400 results.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports rand real.

class rru_obj;
  rand real r;
  constraint c { r >= 0.0; r < 1.0; }
endclass

class rrd_obj;
  rand real v;
  constraint c {
    v dist {0 := 5, 1.5 := 1, [2.0:2.5] :/ 1};
  }
endclass

class rrt_obj;
  rand real v;
  constraint c {
    v dist {0 := 1, [1.0+%-10.0] :/ 1};
  }
endclass

module test_rand_real_uniform_and_dist;
  rru_obj ou = new;
  rrd_obj od = new;
  rrt_obj ot = new;
  int low, high, outside, ufail;
  int n0, n15, nrange, dfail, doutside;
  int t0, ttol, tout, tfail;

  initial begin
    low = 0;
    high = 0;
    outside = 0;
    ufail = 0;
    repeat (1600) begin
      if (!ou.randomize()) ufail++;
      if (ou.r < 0.0 || ou.r >= 1.0) outside++;
      else if (ou.r < 0.5) low++;
      else high++;
    end
    n0 = 0;
    n15 = 0;
    nrange = 0;
    dfail = 0;
    doutside = 0;
    repeat (400) begin
      if (!od.randomize()) dfail++;
      if (od.v == 0.0) n0++;
      else if (od.v == 1.5) n15++;
      else if (od.v >= 2.0 && od.v <= 2.5) nrange++;
      else doutside++;
    end
    t0 = 0;
    ttol = 0;
    tout = 0;
    tfail = 0;
    repeat (400) begin
      if (!ot.randomize()) tfail++;
      if (ot.v == 0.0) t0++;
      else if (ot.v >= 0.9 && ot.v <= 1.1) ttol++;
      else tout++;
    end
    $display("uniform: failures %0d, outside 0..1 %0d, halves 720..880 %0d",
             ufail, outside, low >= 720 && low <= 880 && high >= 720 && high <= 880);
    $display("dist: failures %0d, outside items %0d, 0 more than twice others %0d",
             dfail, doutside, n0 > 2 * (n15 + nrange));
    $display("dist: 1.5 seen %0d, range seen %0d", n15 > 0, nrange > 0);
    $display("tolerance: failures %0d, outside %0d, 0 in 130..270 %0d, tolerance in 130..270 %0d",
             tfail, tout, t0 >= 130 && t0 <= 270, ttol >= 130 && ttol <= 270);
  end
endmodule
