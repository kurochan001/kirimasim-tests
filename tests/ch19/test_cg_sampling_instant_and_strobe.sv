/*
:name: test_cg_sampling_instant_and_strobe
:description: Without strobe a clocking event samples the covergroup at once, every time it occurs in a time step; with type_option.strobe it samples once, at the end of the time slot, while sample() calls and block events are still sampled at once (IEEE 1800-2023 Section 19.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.3 19.7.1 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_sampling_instant_and_strobe.expected
*/
// IEEE 1800-2023 §19.3: when the strobe option is not set, a covergroup with
// a clocking event samples its coverpoints the instant the event occurs, as if
// the process that triggers it called sample(), so an event that occurs
// several times in a time step samples several times. With strobe set, the
// samples are taken in the Postponed region, once per time slot, with the
// values of the end of the slot. Strobe has no effect on a block event or on
// a call of sample(). §19.7.1: type_option.strobe is set at the covergroup
// level and is 0 by default.
//
// Each coverpoint has one bin for one value, so its coverage is 100 when that
// value was sampled and 0 otherwise. A coverpoint with option.at_least = 2
// (19.7) is covered only by two samples of its value. At 1 the test triggers
// e twice while v is 1, then once while v is 2, and leaves v at 3: cg_now
// samples 1 twice and 2 once, cg_strobe samples 3 once. At 2 it calls
// sample() of a strobed covergroup while v is 4 and then sets v to 5, and
// calls the task put_seven, the block event of another strobed covergroup,
// while v is 6; the begin event samples before the task sets v to 7.

module test_cg_sampling_instant_and_strobe;
  event e;
  int v;

  covergroup cg_now @(e);
    one_twice: coverpoint v { option.at_least = 2; bins b = {1}; }
    two: coverpoint v { bins b = {2}; }
    three: coverpoint v { bins b = {3}; }
  endgroup

  covergroup cg_strobe @(e);
    type_option.strobe = 1;
    one: coverpoint v { bins b = {1}; }
    two: coverpoint v { bins b = {2}; }
    three: coverpoint v { bins b = {3}; }
    three_twice: coverpoint v { option.at_least = 2; bins b = {3}; }
  endgroup

  covergroup cg_strobe_call;
    type_option.strobe = 1;
    four: coverpoint v { bins b = {4}; }
    five: coverpoint v { bins b = {5}; }
  endgroup

  covergroup cg_strobe_block @@(begin put_seven);
    type_option.strobe = 1;
    six: coverpoint v { bins b = {6}; }
    seven: coverpoint v { bins b = {7}; }
  endgroup

  cg_now n = new;
  cg_strobe s = new;
  cg_strobe_call c = new;
  cg_strobe_block k = new;

  task put_seven();
    v = 7;
  endtask

  initial begin
    $display("strobe option: cg_now %0d, cg_strobe %0d", cg_now::type_option.strobe,
             cg_strobe::type_option.strobe);
    #1;
    v = 1;
    -> e;
    -> e;
    v = 2;
    -> e;
    v = 3;
    #1;
    $display("no strobe: 1 twice %.0f, 2 %.0f, 3 %.0f", n.one_twice.get_inst_coverage(),
             n.two.get_inst_coverage(), n.three.get_inst_coverage());
    $display("strobe: 1 %.0f, 2 %.0f, 3 %.0f, 3 twice %.0f", s.one.get_inst_coverage(),
             s.two.get_inst_coverage(), s.three.get_inst_coverage(),
             s.three_twice.get_inst_coverage());
    v = 4;
    c.sample();
    v = 5;
    v = 6;
    put_seven();
    #1;
    $display("strobe, sample(): 4 %.0f, 5 %.0f", c.four.get_inst_coverage(),
             c.five.get_inst_coverage());
    $display("strobe, block event: 6 %.0f, 7 %.0f", k.six.get_inst_coverage(),
             k.seven.get_inst_coverage());
  end
endmodule
