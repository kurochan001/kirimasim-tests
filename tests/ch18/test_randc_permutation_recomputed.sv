/*
:name: test_randc_permutation_recomputed
:description: The permutation of a randc variable is computed again when its constraints change and when none of its remaining values satisfies the constraints, and it holds only 2-state values (IEEE 1800-2023 Section 18.4.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4.2 18.9
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_randc_permutation_recomputed.expected
*/
// IEEE 1800-2023 §18.4.2: the permutation of a randc variable is computed
// again whenever the constraints on the variable change, or when none of the
// values left in the permutation satisfies the constraints; the permutation
// contains only 2-state values. x is a randc logic [1:0].
// Part 1, none of the remaining values fits: with use_pair 0, two calls give
// a and b; then pa=a, pb=b and use_pair=1, so c_pair now asks for x inside
// {a, b}. The two values left in the permutation are neither a nor b, so a
// new permutation over {a, b} is needed: both later calls succeed and give a
// and b once each. Only the values of state variables changed here.
// Part 2, a remaining value still fits: with the block c_next turned off by
// constraint_mode() (18.9), one call gives f; then qa=f, qb=f+1 and c_next
// is turned on, which changes the constraints on x. f+1 is still in the old
// permutation, but the change starts a new permutation over {f, f+1}, which
// gives f and f+1 once each in the next two calls. Keeping the old
// permutation would give f+1 first and then a new permutation, which repeats
// f+1 with probability 1/2 in each of the 20 rounds.
// Part 3: in 3 runs of 4 calls without constraints, x is never x or z and
// takes each of the values 0 to 3 once per run.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 fails part 1: in some rounds the two calls after use_pair=1 do not
// give a and b once each.

class rpr_obj;
  randc logic [1:0] x;
  bit use_pair;
  bit [1:0] pa, pb, qa, qb;
  constraint c_pair { use_pair -> x inside {pa, pb}; }
  constraint c_next { x inside {qa, qb}; }
endclass

module test_randc_permutation_recomputed;
  rpr_obj o;
  bit [1:0] v1, v2;
  bit [3:0] seen;
  int ok, bad, unknown, incomplete;

  initial begin
    o = new;
    o.c_next.constraint_mode(0);

    ok = 1;
    bad = 0;
    repeat (20) begin
      o.use_pair = 0;
      ok &= o.randomize();
      o.pa = o.x;
      ok &= o.randomize();
      o.pb = o.x;
      o.use_pair = 1;
      ok &= o.randomize();
      v1 = o.x;
      ok &= o.randomize();
      v2 = o.x;
      if (v1 == v2 || !(v1 inside {o.pa, o.pb}) || !(v2 inside {o.pa, o.pb})) bad++;
    end
    $display("no remaining value fits: all calls succeeded=%0d bad rounds=%0d", ok, bad);

    o.use_pair = 0;
    ok = 1;
    bad = 0;
    repeat (20) begin
      o.c_next.constraint_mode(0);
      ok &= o.randomize();
      o.qa = o.x;
      o.qb = o.x + 2'd1;
      o.c_next.constraint_mode(1);
      ok &= o.randomize();
      v1 = o.x;
      ok &= o.randomize();
      v2 = o.x;
      if (v1 == v2 || !(v1 inside {o.qa, o.qb}) || !(v2 inside {o.qa, o.qb})) bad++;
    end
    $display("constraints changed: all calls succeeded=%0d bad rounds=%0d", ok, bad);

    o.c_next.constraint_mode(0);
    ok = 1;
    unknown = 0;
    incomplete = 0;
    repeat (3) begin
      seen = 0;
      repeat (4) begin
        ok &= o.randomize();
        if ($isunknown(o.x)) unknown++;
        else seen[o.x] = 1'b1;
      end
      if (seen != 4'b1111) incomplete++;
    end
    $display("unconstrained: all calls succeeded=%0d unknown=%0d incomplete runs=%0d", ok,
             unknown, incomplete);
  end
endmodule
