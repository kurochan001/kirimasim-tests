/*
:name: test_discarded_soft_distribution
:description: A discarded soft constraint is replaced by true and has no effect on the distribution, so a soft dist that a higher-priority soft constraint contradicts leaves the remaining values equally likely, and two soft constraints contradicted by a hard one are both discarded (IEEE 1800-2023 Sections 18.5.13 and 18.5.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13 18.5.13.1 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_discarded_soft_distribution.expected
*/
// IEEE 1800-2023 §18.5.13: a discarded soft constraint is treated as true and
// has no effect on the solution distribution. In ds_dist the soft dist asks
// for v == 0 with weight 9 and v == 7 with weight 1; the later, higher-priority
// soft constraint v inside {3,4} contradicts every value of that dist, so the
// dist is discarded and v is uniformly 3 or 4, not biased toward 3.
// In ds_both the hard x == 3 contradicts both soft constraints, so the solver
// discards both and still succeeds with x == 3.
// In Verilator 5.052 the discarded soft dist still decides the value of v.

class ds_dist;
  rand bit [2:0] v;
  constraint c1 { soft v dist {0 := 9, 7 := 1}; }
  constraint c2 { soft v inside {[3:4]}; }
endclass

class ds_both;
  rand int x;
  constraint c1 { soft x == 1; }
  constraint c2 { soft x == 2; }
  constraint h { x == 3; }
endclass

module test_discarded_soft_distribution;
  ds_dist od = new;
  ds_both ob = new;
  int n3, n4, outside, failed, wrong, bfailed;

  initial begin
    n3 = 0;
    n4 = 0;
    outside = 0;
    failed = 0;
    repeat (400) begin
      if (!od.randomize()) failed++;
      else if (od.v == 3) n3++;
      else if (od.v == 4) n4++;
      else outside++;
    end
    $display("discarded dist: failed %0d, outside 3,4 %0d, 3 and 4 each 130..270 %0d",
             failed, outside, n3 >= 130 && n3 <= 270 && n4 >= 130 && n4 <= 270);
    wrong = 0;
    bfailed = 0;
    repeat (200) begin
      if (!ob.randomize()) bfailed++;
      else if (ob.x != 3) wrong++;
    end
    $display("both discarded: failed %0d, wrong %0d", bfailed, wrong);
  end
endmodule
