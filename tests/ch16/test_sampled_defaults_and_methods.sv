/*
:name: test_sampled_defaults_and_methods
:description: at the first clock tick a past reference gives the default sampled value of each kind of variable, net, event method and sequence method, while at later ticks it gives the Postponed value of the previous tick, and the sampled value of sequence.triggered is its current result (IEEE 1800-2023 Sections 16.5.1 and 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5.1 16.13.6 16.9.3 16.9.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sampled_defaults_and_methods.expected
*/
// IEEE 1800-2023 §16.5.1: the default sampled value of a static variable is
// the value assigned in its declaration or else the default of its type, and
// the default sampled value of any other variable or net is the default of its
// type, which is x for a 4-state logic. The default sampled values of
// event.triggered and sequence.triggered are false. A past reference at the
// first clock tick gives these defaults; at a later tick it gives the sampled
// value of the previous tick, taken in its Postponed region. §16.13.6: the
// sampled value of sequence.triggered is its current result, set in the
// Observed region and kept for the rest of the time step, so a cover property
// on it succeeds at the tick that ends the sequence. lv and nv are 4-state
// without an initializer; nv is a net whose continuous value is not a sampled
// value. The sequence s is a ##1 b, with a high at the tick at 5 and b high at
// the tick at 15, so s ends at 15. e triggers at 15 as well. Sequence.matched
// is not used in a sampled value function, which §16.13.6 makes an error.

`timescale 1ns/1ns

module test_sampled_defaults_and_methods;
  logic clk = 0, a = 0, b = 0;
  logic [3:0] lv;
  int iv;
  int sv = 7;
  wire [3:0] nv = 4'h5;
  event e;
  int trig_at[$], sampled_trig_at[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  sequence s;
    a ##1 b;
  endsequence

  a_obs: assert property (@(posedge clk) 1'b1) begin
    if ($time == 5)
      $display("defaults: lv=%b iv=%0d sv=%0d nv=%b event=%0d triggered=%0d",
               $past(lv), $past(iv), $past(sv),
               $past(nv), $past(e.triggered), $past(s.triggered));
    else
      $display("t=%0t past triggered=%0d event=%0d", $time,
               $past(s.triggered), $past(e.triggered));
  end

  c_trig: cover property (@(posedge clk) s.triggered)
    trig_at.push_back($time);
  c_samp: cover property (@(posedge clk) $sampled(s.triggered))
    sampled_trig_at.push_back($time);

  function automatic string times(int q[$]);
    string t = "";
    foreach (q[i]) t = {t, $sformatf(" %0d", q[i])};
    return t;
  endfunction

  initial begin
    a = 1;
    #10 b = 1;
    a = 0;
    #5 -> e;   // in the time step of the tick at 15
    #25;
    $display("triggered covered at:%s", times(trig_at));
    $display("sampled triggered covered at:%s", times(sampled_trig_at));
    $finish;
  end
endmodule
