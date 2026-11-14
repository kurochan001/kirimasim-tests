/*
:name: test_disable_soft_enclosing_condition_kept
:description: disable soft p keeps a lower-priority soft constraint guarded by p in an implication, because p is only in the enclosing condition and not in the soft expression, while it drops a soft expression in which p itself appears, and disable soft q drops the guarded soft constraint on q (IEEE 1800-2023 Section 18.5.13.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_soft_enclosing_condition_kept.expected
*/
// IEEE 1800-2023 §18.5.13.2: disable soft v discards the soft constraints of
// lower priority that reference v, and only those in which v directly
// appears. In p -> soft q == 5 the soft expression is q == 5; p is only the
// condition that encloses it. Each class has p == 1 as a hard constraint and
// a 4-bit q, and its disable soft block comes last, so it has the highest
// priority (18.5.13.1).
// - dsk_cond: disable soft p does not reach p -> soft q == 5, so q is 5
//   after every call.
// - dsk_target: disable soft q discards that soft constraint, since q is in
//   its expression; nothing else constrains q, which then takes other values.
// - dsk_direct: the soft expression !p || q == 5 names p itself, so
//   disable soft p discards it and q is free again.
// - dsk_none: the same soft expression without disable soft holds, and with
//   p == 1 it makes q 5.
// Each object is randomized 40 times. A free 4-bit q is 5 in all 40 calls
// with probability 16 to the power -40, so "q always 5" is 1 exactly where
// the soft constraint on q is kept. If disable soft p also discarded the
// soft constraint that p only guards, the first line would end with 0.
// Icarus Verilog 13.0 does not support constraints. The 5.054 release of
// the Verilator simulator keeps p -> soft q == 5 under disable soft q too, so
// its second line ends with 1; its other lines are as expected.

class dsk_cond;
  rand bit p;
  rand bit [3:0] q;
  constraint c_p { p == 1; }
  constraint c_1 { p -> soft q == 5; }
  constraint c_3 { disable soft p; }
endclass

class dsk_target;
  rand bit p;
  rand bit [3:0] q;
  constraint c_p { p == 1; }
  constraint c_1 { p -> soft q == 5; }
  constraint c_3 { disable soft q; }
endclass

class dsk_direct;
  rand bit p;
  rand bit [3:0] q;
  constraint c_p { p == 1; }
  constraint c_2 { soft !p || q == 5; }
  constraint c_3 { disable soft p; }
endclass

class dsk_none;
  rand bit p;
  rand bit [3:0] q;
  constraint c_p { p == 1; }
  constraint c_2 { soft !p || q == 5; }
endclass

module test_disable_soft_enclosing_condition_kept;
  dsk_cond oc = new;
  dsk_target ot = new;
  dsk_direct od = new;
  dsk_none on = new;
  int fails[4];
  bit always5[4];

  initial begin
    foreach (always5[i]) always5[i] = 1;
    repeat (40) begin
      if (!oc.randomize()) fails[0]++;
      else if (oc.q != 5) always5[0] = 0;
      if (!ot.randomize()) fails[1]++;
      else if (ot.q != 5) always5[1] = 0;
      if (!od.randomize()) fails[2]++;
      else if (od.q != 5) always5[2] = 0;
      if (!on.randomize()) fails[3]++;
      else if (on.q != 5) always5[3] = 0;
    end
    $display("disable soft p, p only in the condition: failures %0d, q always 5: %0d",
             fails[0], always5[0]);
    $display("disable soft q, q in the soft expression: failures %0d, q always 5: %0d",
             fails[1], always5[1]);
    $display("disable soft p, p in the soft expression: failures %0d, q always 5: %0d",
             fails[2], always5[2]);
    $display("no disable soft, p in the soft expression: failures %0d, q always 5: %0d",
             fails[3], always5[3]);
  end
endmodule
