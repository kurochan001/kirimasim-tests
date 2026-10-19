/*
:name: test_randomize_null_checker
:description: randomize(null) only checks the constraints, and randomize with a list of variables randomizes only those (IEEE 1800-2023 Section 18.11.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.11.1 18.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_null_checker.expected
*/
// IEEE 1800-2023 §18.11.1: randomize(null) treats every variable as a state
// variable, so it changes nothing and returns 1 if the constraints hold for the
// current values and 0 if they do not. §18.11: randomize(x) makes only x random
// for that call; the other variables keep their values and act as state
// variables in the constraints.

class rnc_obj;
  rand int x, y;
  constraint c { x < y; }
endclass

module test_randomize_null_checker;
  rnc_obj o;
  int r;
  int bad = 0;

  initial begin
    o = new;
    o.x = 1; o.y = 2;
    r = o.randomize(null);
    $display("x=1 y=2: check=%0d x=%0d y=%0d", r, o.x, o.y);
    o.x = 5;
    r = o.randomize(null);
    $display("x=5 y=2: check=%0d x=%0d y=%0d", r, o.x, o.y);
    o.y = 50;
    repeat (20) begin
      r = o.randomize(x);
      if (r != 1 || o.y != 50 || !(o.x < 50)) bad++;
    end
    $display("randomize(x) with y=50: violations=%0d y=%0d", bad, o.y);
  end
endmodule
