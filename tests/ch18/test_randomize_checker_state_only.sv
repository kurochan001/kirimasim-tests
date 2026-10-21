/*
:name: test_randomize_checker_state_only
:description: randomize() of an object without random variables, and randomize(null), only check the constraints and change nothing, and the result follows constraint_mode, rand_mode and if-else constraints on state variables as they change between calls (IEEE 1800-2023 Section 18.11.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.11.1 18.10 18.8 18.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_checker_state_only.expected
*/
// IEEE 1800-2023 §18.11.1: randomize() of an object of a class without
// random variables, like randomize(null) of any object, assigns nothing and
// returns 1 when all the constraints hold for the current values and 0
// otherwise. §18.10: the constraints can change between calls:
// - a block turned off with constraint_mode(0) (18.9) is ignored, so the
//   check of lo < hi passes with lo = 3 and hi = 2 until it is on again;
// - an if-else constraint on the state variable mode applies x > 10 or
//   x < 5, and randomize(null) checks the one that mode selects;
// - with rand_mode(0) (18.8), x is a state variable, so randomize() checks
//   it like randomize(null) and keeps its value; with rand_mode(1) x is
//   random again and gets a value below 5 when mode is 0.
// In Verilator 5.052, randomize() of rcs_cfg, which has no random variables,
// returns 1 also when lo < hi does not hold.

class rcs_cfg;
  int lo, hi;
  constraint c_order { lo < hi; }
endclass

class rcs_obj;
  rand bit [3:0] x;
  bit mode;
  constraint c_pred { if (mode) x > 4'd10; else x < 4'd5; }
endclass

module test_randomize_checker_state_only;
  rcs_cfg cfg;
  rcs_obj o;
  int r1, r2, r3;

  initial begin
    cfg = new;
    cfg.lo = 1; cfg.hi = 2;
    r1 = cfg.randomize();
    cfg.lo = 3;
    r2 = cfg.randomize();
    $display("no random variables: lo<hi %0d, lo>hi %0d, lo=%0d hi=%0d", r1, r2, cfg.lo, cfg.hi);
    cfg.c_order.constraint_mode(0);
    r1 = cfg.randomize();
    cfg.c_order.constraint_mode(1);
    r2 = cfg.randomize();
    $display("c_order off: %0d, on again: %0d", r1, r2);

    o = new;
    o.x = 4'd12;
    o.mode = 1;
    r1 = o.randomize(null);
    o.mode = 0;
    r2 = o.randomize(null);
    o.x = 4'd3;
    r3 = o.randomize(null);
    $display("randomize(null): x=12 mode=1 %0d, x=12 mode=0 %0d, x=3 mode=0 %0d, x=%0d",
             r1, r2, r3, o.x);

    o.x.rand_mode(0);
    o.x = 4'd12;
    o.mode = 1;
    r1 = o.randomize();
    o.mode = 0;
    r2 = o.randomize();
    $display("x inactive: mode=1 %0d, mode=0 %0d, x=%0d", r1, r2, o.x);
    o.x.rand_mode(1);
    r3 = o.randomize();
    $display("x active, mode=0: %0d, x<5 %0d", r3, o.x < 4'd5);
  end
endmodule
