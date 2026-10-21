/*
:name: test_global_constraints_nested_inactive
:description: The active random objects of randomize() are those reached through active rand handles, at any depth, while an object whose rand handle is not random in the call, and the objects reached only through it, keep their values and their constraints are not applied (IEEE 1800-2023 Section 18.5.8)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.8 18.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_constraints_nested_inactive.expected
*/
// IEEE 1800-2023 §18.5.8: randomize() collects the active random objects
// recursively, starting with the object it is called on and following its
// active rand handles; their constraints are solved together, and every
// other variable is a state variable. top reaches mid and, through mid, leaf,
// which is two handles away, and side. In the first part leaf.v follows
// mid.v and top.v while its own constraint keeps it in [100:200].
// randomize(v, mid) makes v and mid the only random variables of top for
// the call (18.11), so the handle side is inactive: side.v = 3 is a state
// variable and the constraint of side, v > 200, is not applied (if it were,
// the call would fail), so the implication in top fixes top.v to 120.
// Then randomize(v, side) leaves out mid, so mid and leaf, reached only
// through mid, are not randomized: mid.v = 50 fixes top.v to 49, and leaf
// keeps 7, although its own constraint and that of mid would not allow it.
// In Verilator 5.052, a rand handle left out of the arguments of randomize()
// stays active: side, and then mid and leaf, are randomized.

class gni_leaf;
  rand bit [7:0] v;
  constraint c_leaf { v inside {[100:200]}; }
endclass

class gni_side;
  rand bit [7:0] v;
  constraint c_side { v > 8'd200; }
endclass

class gni_mid;
  rand bit [7:0] v;
  rand gni_leaf leaf;
  constraint c_mid { leaf.v == v + 8'd1; }
  function new();
    leaf = new;
  endfunction
endclass

class gni_top;
  rand bit [7:0] v;
  rand gni_mid mid;
  rand gni_side side;
  constraint c_top { mid.v == v + 8'd1; (side.v < 8'd50) -> v == 8'd120; }
  function new();
    mid = new;
    side = new;
  endfunction
endclass

module test_global_constraints_nested_inactive;
  gni_top t;
  int failed = 0, bad = 0;
  int ok;

  initial begin
    t = new;
    repeat (20) begin
      if (!t.randomize()) failed++;
      if (t.mid.v != t.v + 8'd1 || t.mid.leaf.v != t.mid.v + 8'd1) bad++;
      if (!(t.mid.leaf.v inside {[100:200]}) || t.side.v <= 8'd200) bad++;
    end
    $display("all active, 20 calls: failed=%0d violations=%0d", failed, bad);

    t.side.v = 8'd3;
    ok = t.randomize(v, mid);
    $display("randomize(v, mid): ok=%0d top=%0d mid=%0d leaf=%0d side=%0d",
             ok, t.v, t.mid.v, t.mid.leaf.v, t.side.v);

    t.mid.v = 8'd50;
    t.mid.leaf.v = 8'd7;
    ok = t.randomize(v, side);
    $display("randomize(v, side): ok=%0d top=%0d mid=%0d leaf=%0d side>200=%0d",
             ok, t.v, t.mid.v, t.mid.leaf.v, t.side.v > 8'd200);
  end
endmodule
