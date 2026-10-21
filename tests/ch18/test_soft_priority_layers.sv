/*
:name: test_soft_priority_layers
:description: Priorities of soft constraints follow the order of the prototypes of external blocks, put a derived class above its base, a container above the objects it holds, a later handle above an earlier one and a later foreach iteration above an earlier one, and a call with only soft constraints never fails (IEEE 1800-2023 Section 18.5.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.1 18.5.13 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_priority_layers.expected
*/
// IEEE 1800-2023 §18.5.13.1: when two soft constraints contradict, the one of
// higher priority is kept. Each pair here contradicts, so one rule decides
// each value:
// - external blocks (18.5.1) rank by the order of their prototypes, not of
//   the blocks: c_first is declared first and completed last, so p == 20 of
//   c_second wins;
// - a derived class ranks above its base: b == 2;
// - the container ranks above the objects it holds: h1.v == 7, not the 3 of
//   the soft constraint of h1;
// - of two held objects, the one whose handle is declared later ranks
//   higher: h2.v == h3.v is hard, and h3 asks for 9, h2 for 8, so both are 9;
// - a later iteration of foreach ranks higher: r == 6, the last of 4, 5, 6;
// - a soft constraint is dropped only when a more important one contradicts
//   it, so s > 5 and s < 7, which contradict nothing, both hold: s == 6.
// A call whose constraints are all soft never fails (18.5.13): for spl_only,
// t > 5 is kept and the two lower ones that contradict it are dropped.
// In Verilator 5.052, external blocks rank in the order of the blocks
// themselves, so p is 10.

class spl_inner;
  rand int v;
  int pref;
  constraint c_in { soft v == pref; }
endclass

class spl_base;
  rand int b;
  constraint c_base { soft b == 1; }
endclass

class spl_obj extends spl_base;
  rand int p, r, s;
  rand spl_inner h1, h2, h3;
  int prefs[3] = '{4, 5, 6};
  constraint c_first;
  constraint c_second;
  constraint c_der { soft b == 2; }
  constraint c_hold { soft h1.v == 7; h2.v == h3.v; }
  constraint c_each { foreach (prefs[i]) soft r == prefs[i]; }
  constraint c_free { soft s > 5; soft s < 7; }
  function new();
    h1 = new; h2 = new; h3 = new;
    h1.pref = 3; h2.pref = 8; h3.pref = 9;
  endfunction
endclass

constraint spl_obj::c_second { soft p == 20; }
constraint spl_obj::c_first { soft p == 10; }

class spl_only;
  rand int t;
  constraint c_t { soft t == 1; soft t == 2; soft t > 5; }
endclass

module test_soft_priority_layers;
  spl_obj o;
  spl_only so;
  int ok;
  int failed = 0, bad = 0;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d", ok);
    $display("prototype order: p=%0d", o.p);
    $display("derived over base: b=%0d", o.b);
    $display("container over held object: h1.v=%0d", o.h1.v);
    $display("later handle: h2.v=%0d h3.v=%0d", o.h2.v, o.h3.v);
    $display("later iteration: r=%0d", o.r);
    $display("no contradiction: s=%0d", o.s);
    so = new;
    repeat (20) begin
      if (!so.randomize()) failed++;
      if (so.t <= 5) bad++;
    end
    $display("only soft constraints, 20 calls: failed=%0d t<=5: %0d", failed, bad);
  end
endmodule
