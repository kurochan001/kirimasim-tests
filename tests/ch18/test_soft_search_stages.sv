/*
:name: test_soft_search_stages
:description: Soft constraints are searched from both to the higher, the lower and then neither, a discarded soft constraint acts as true and has no effect on the solution distribution, and a call with only soft constraints cannot fail (IEEE 1800-2023 Sections 18.5.13 and 18.5.13.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13 18.5.13.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_search_stages.expected
*/
// IEEE 1800-2023 §18.5.13, §18.5.13.1: of two contradicting soft constraints
// the later declared one has the higher priority. The solver first tries both,
// then only the higher, then only the lower, then discards both, keeping the
// hard constraints. ss_both satisfies both soft constraints; ss_high keeps the
// higher x == 2; ss_low has the hard x == 1, which contradicts the higher
// x == 2 but satisfies the lower x == 1; ss_none has the hard x == 3, which
// contradicts both.

class ss_both;
  rand int x;
  constraint c { soft x inside {[0:10]}; soft x != 5; }
endclass

class ss_high;
  rand int x;
  constraint c1 { soft x == 1; }
  constraint c2 { soft x == 2; }
endclass

class ss_low;
  rand int x;
  constraint c1 { soft x == 1; }
  constraint c2 { soft x == 2; }
  constraint h { x == 1; }
endclass

class ss_none;
  rand int x;
  constraint c1 { soft x == 1; }
  constraint c2 { soft x == 2; }
  constraint h { x == 3; }
endclass

module test_soft_search_stages;
  ss_both ob = new;
  ss_high oh = new;
  ss_low ol = new;
  ss_none on = new;
  int b_bad, f_bad, h_bad, l_bad, n_bad;

  initial begin
    b_bad = 0;
    f_bad = 0;
    h_bad = 0;
    l_bad = 0;
    n_bad = 0;
    repeat (200) begin
      if (!ob.randomize()) b_bad++;
      else if (ob.x < 0 || ob.x > 10 || ob.x == 5) b_bad++;
      if (!oh.randomize()) h_bad++;
      else if (oh.x != 2) h_bad++;
      if (!ol.randomize()) l_bad++;
      else if (ol.x != 1) l_bad++;
      if (!on.randomize()) n_bad++;
      else if (on.x != 3) n_bad++;
    end
    $display("both soft: wrong %0d, higher only: wrong %0d",
             b_bad, h_bad);
    $display("lower only: wrong %0d, both discarded: wrong %0d",
             l_bad, n_bad);
  end
endmodule
