/*
:name: test_multiclock_implication_if_sync
:description: a multiclocked |-> checks its consequent at the nearest tick of the consequent clock at or after the end of the antecedent, |=> at the nearest tick strictly after each end of the antecedent, the branches of a multiclocked if-else at the nearest tick of their own clocks at or after the condition, and a multiclocked sequence asserted as a property is true or false at each attempt (IEEE 1800-2023 Section 16.13.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.2 16.13.1 16.12.6 16.12.7 16.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiclock_implication_if_sync.expected
*/
// IEEE 1800-2023 §16.13.2: the result of a multiclocked property is true or
// false, and a multiclocked sequence used as a property is true at a start
// point if a match of it begins there. In a multiclocked |-> the consequent
// waits for the nearest tick of its own clock at or after the end of the
// antecedent: a tick in that same time step starts it at once. In |=>, for
// each match of the antecedent, the consequent starts at the nearest tick of
// its clock strictly after the end of that match. A multiclocked if-else
// tests its condition at the tick of the outer clock and checks the chosen
// branch at the nearest tick of the branch clock at or after it, in both the
// if and the else branch. §16.13.1: in a multiclocked sequence ##1 moves to
// the nearest tick of the next clock strictly after.
// Each antecedent clock (ca, cb, cc, cm, cd) ticks only at the times listed
// in the code, so every attempt is visible; the pass and fail actions
// (§16.14.1) record the times of the results. Every tick has a twin: a_ov at
// 10 and a_if at 130 have a consequent-clock tick in the same time step, where
// x is 1 and 0, followed 4 later by a tick with the opposite value; a_no at 70
// has the same pattern and has to skip the tick at 70; a_ov at 40, a_no at 100
// and a_if at 160 have their nearest tick 4 later and a tick with the opposite
// value 4 after that; the else branch of a_if has the same two patterns on c2
// at 190 and 220. a_mm starts at 250 and its antecedent m1 ##[1:2] m2 (§16.7)
// matches at the cm ticks 260 and 270: x is 1 at the c1 tick 265 after the
// first end but 0 at 275 after the second, so the attempt fails at 275; the
// attempts at 260 and 270 succeed vacuously. a_sq is a sequence on cd then c1.
// A signal listed as high at a time is sampled high at the tick at that time.

`timescale 1ns/1ns

module test_multiclock_implication_if_sync;
  logic ca = 0, cb = 0, cc = 0, cm = 0, cd = 0, c1 = 0, c2 = 0;
  logic a = 1, sel = 0, x = 0, y = 0, m1 = 0, m2 = 0, d = 0;
  int p_ov[$], f_ov[$], p_no[$], f_no[$], p_if[$], f_if[$];
  int p_mm[$], f_mm[$], p_sq[$], f_sq[$];

  int ca_t[$] = '{10, 40};
  int cb_t[$] = '{70, 100};
  int cc_t[$] = '{130, 160, 190, 220};
  int cm_t[$] = '{250, 260, 270};
  int cd_t[$] = '{330, 360};
  int c1_t[$] = '{10, 14, 44, 48, 70, 74, 104, 108, 130, 134, 164, 168, 255, 265, 275, 334,
                  364};
  int c2_t[$] = '{190, 194, 224, 228};

  a_ov: assert property (@(posedge ca) a |-> @(posedge c1) x)
    p_ov.push_back($time); else f_ov.push_back($time);
  a_no: assert property (@(posedge cb) a |=> @(posedge c1) x)
    p_no.push_back($time); else f_no.push_back($time);
  a_if: assert property (@(posedge cc) if (sel) @(posedge c1) x else @(posedge c2) y)
    p_if.push_back($time); else f_if.push_back($time);
  a_mm: assert property (@(posedge cm) m1 ##[1:2] m2 |=> @(posedge c1) x)
    p_mm.push_back($time); else f_mm.push_back($time);
  a_sq: assert property (@(posedge cd) d ##1 @(posedge c1) x)
    p_sq.push_back($time); else f_sq.push_back($time);

  // True when a signal sampled high at the times listed has to be high at t:
  // it is high from one time unit before each such time.
  function automatic logic at(int t, int times[$]);
    foreach (times[i]) if (t == times[i] - 1 || t == times[i]) return 1'b1;
    return 1'b0;
  endfunction

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    for (int t = 0; t < 380; t++) begin
      ca = t inside {ca_t};
      cb = t inside {cb_t};
      cc = t inside {cc_t};
      cm = t inside {cm_t};
      cd = t inside {cd_t};
      c1 = t inside {c1_t};
      c2 = t inside {c2_t};
      x = at(t, '{10, 48, 70, 104, 134, 164, 265, 334});
      y = at(t, '{190, 228});
      sel = at(t, '{130, 160});
      m1 = at(t, '{250});
      m2 = at(t, '{260, 270});
      d = at(t, '{330, 360});
      #1;
    end
    $display("@(posedge ca) a |-> @(posedge c1) x: passes%s; failures%s", times(p_ov),
             times(f_ov));
    $display("@(posedge cb) a |=> @(posedge c1) x: passes%s; failures%s", times(p_no),
             times(f_no));
    $display("@(posedge cc) if (sel) @(posedge c1) x else @(posedge c2) y: passes%s; failures%s",
             times(p_if), times(f_if));
    $display("@(posedge cm) m1 ##[1:2] m2 |=> @(posedge c1) x: passes%s; failures%s",
             times(p_mm), times(f_mm));
    $display("@(posedge cd) d ##1 @(posedge c1) x: passes%s; failures%s", times(p_sq),
             times(f_sq));
    $finish;
  end
endmodule
