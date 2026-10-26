/*
:name: test_constraint_if_else_bidirectional
:description: An if-else constraint makes the condition and the variables of the selected set constrain each other, a set can group several constraints, if-else equals the corresponding implications, and an else belongs to the nearest if (IEEE 1800-2023 Section 18.5.6)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_if_else_bidirectional.expected
*/
// IEEE 1800-2023 §18.5.6: the condition of an if-else constraint and the
// variables of the selected constraint set constrain each other. In ifb both
// v and w are random: the first branch allows w the two values 0 and 1, the
// else branch only w == 2, so the six legal pairs are (v, 0), (v, 1) for
// v == 2 and 3 and (v, 2) for v == 0 and 1. All six have the same
// probability (18.5.9), so v > 1 in four of six calls. If the condition were
// solved from v alone, v > 1 would be true in half of the calls, and if the
// two variables were solved independently, pairs such as (0, 0) would occur.
// In ifs one branch holds two constraints in braces, and imp states the same
// conditions as implications; both must produce (m == 0, a == 1, b == 2) or
// (m != 0, a == 3, b == 4).
// In nel the else belongs to the inner if: mode 0 gives x == 1, mode 1 gives
// x == 2, and mode 2 leaves x free, which takes several values.

class ifb_obj;
  rand bit [1:0] v, w;
  constraint c {
    if (v > 1) w inside {0, 1};
    else w == 2;
  }
endclass

class ifs_obj;
  rand bit [1:0] m;
  rand bit [3:0] a, b;
  constraint c {
    if (m == 0) {
      a == 1;
      b == 2;
    } else {
      a == 3;
      b == 4;
    }
  }
endclass

class imp_obj;
  rand bit [1:0] m;
  rand bit [3:0] a, b;
  constraint c {
    m == 0 -> a == 1;
    m == 0 -> b == 2;
    m != 0 -> a == 3;
    m != 0 -> b == 4;
  }
endclass

class nel_obj;
  rand bit [1:0] mode;
  rand bit [1:0] x;
  constraint c {
    if (mode != 2)
      if (mode == 0) x == 1;
      else x == 2;
  }
endclass

module test_constraint_if_else_bidirectional;
  ifb_obj ob = new;
  ifs_obj os = new;
  imp_obj oi = new;
  nel_obj on = new;
  int fb, sb, ib, n1, nfree;
  int s0, s1, i0, i1;
  int hi, low, pairs;
  int combo[16];
  int nfree_values[4];

  initial begin
    fb = 0;
    hi = 0;
    low = 0;
    foreach (combo[i]) combo[i] = 0;
    repeat (600) begin
      if (!ob.randomize()) fb++;
      else begin
        if (ob.v > 1) begin
          hi++;
          if (ob.w > 1) fb++;
        end else begin
          low++;
          if (ob.w != 2) fb++;
        end
        combo[{ob.v, ob.w}]++;
      end
    end
    pairs = 0;
    foreach (combo[i]) if (combo[i] > 0) pairs++;
    $display("bidirectional: failures %0d, v>1 in 350..450 %0d, legal pairs %0d",
             fb, hi >= 350 && hi <= 450, pairs);
    sb = 0;
    s0 = 0;
    s1 = 0;
    foreach (nfree_values[i]) nfree_values[i] = 0;
    repeat (400) begin
      if (!os.randomize()) sb++;
      else if (os.m == 0 && os.a == 1 && os.b == 2) s0++;
      else if (os.m != 0 && os.a == 3 && os.b == 4) s1++;
      else sb++;
    end
    $display("if/else grouped set: failures %0d, both branches %0d",
             sb, s0 > 0 && s1 > 0);
    ib = 0;
    i0 = 0;
    i1 = 0;
    repeat (400) begin
      if (!oi.randomize()) ib++;
      else if (oi.m == 0 && oi.a == 1 && oi.b == 2) i0++;
      else if (oi.m != 0 && oi.a == 3 && oi.b == 4) i1++;
      else ib++;
    end
    $display("implications: failures %0d, both branches %0d",
             ib, i0 > 0 && i1 > 0);
    n1 = 0;
    nfree = 0;
    foreach (nfree_values[i]) nfree_values[i] = 0;
    repeat (600) begin
      if (!on.randomize()) n1++;
      else if (on.mode == 1 && on.x != 2) n1++;
      else if (on.mode == 0 && on.x != 1) n1++;
      else if (on.mode == 2) nfree_values[on.x]++;
    end
    foreach (nfree_values[i]) if (nfree_values[i] > 0) nfree++;
    $display("nearest else: wrong results %0d, mode 2 takes several values %0d",
             n1, nfree > 1);
  end
endmodule
