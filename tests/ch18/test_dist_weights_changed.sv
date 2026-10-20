/*
:name: test_dist_weights_changed
:description: Constraints can be changed between calls of randomize(): the weights of a dist can be variables, a weight of 0 keeps a value from being chosen, and a state variable in an implication switches a constraint on and off (IEEE 1800-2023 Section 18.10)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.10 18.5.3 18.5.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_weights_changed.expected
*/
// IEEE 1800-2023 §18.10: randomization constraints can be changed while the
// simulation runs, among other ways by implication constraints that depend on
// state variables (18.5.6) and by changing the weights of a dist (18.5.3). A
// value whose weight is 0 is never chosen, so with only one nonzero weight the
// value is fixed whatever the random generator does. pick has the weights w0,
// w1 and w2; when strict is 1 the implication also forces big to 7.

module test_dist_weights_changed;
  class chooser;
    int w0 = 1, w1 = 0, w2 = 0;
    bit strict = 0;
    rand int pick;
    rand int big;
    constraint c_pick { pick dist { 0 := w0, 1 := w1, 2 := w2 }; }
    constraint c_big { big inside {[0:100]}; strict -> big == 7; }
  endclass

  chooser c;
  int ok;
  string seen;

  initial begin
    c = new();
    seen = "";
    repeat (3) begin
      ok = c.randomize();
      seen = {seen, $sformatf(" %0d", c.pick)};
    end
    c.w0 = 0;
    c.w2 = 5;
    c.strict = 1;
    repeat (3) begin
      ok = ok & c.randomize();
      seen = {seen, $sformatf(" %0d/%0d", c.pick, c.big)};
    end
    $display("all succeeded: %0d, picks:%s", ok, seen);
  end
endmodule
