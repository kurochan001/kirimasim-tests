/*
:name: test_cg_transition_binsof_last_value
:description: A binsof select expression applied to a transition bin uses the last value of the transition, so a cross bin intersects both transitions that end in the selected value (IEEE 1800-2023 Section 19.6.1.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.1 19.6.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_transition_binsof_last_value.expected
*/
// IEEE 1800-2023 §19.6.1.1: when a select expression names a transition bin,
// binsof uses the last value of the transition. Cross X crosses tp, whose
// bins t12 is 1=>2 and t32 is 3=>2, with cb, whose bins are lo (0) and hi (1).
// The user bin sel = binsof(tp) intersect {2} therefore selects the four
// products of t12 and t32 with lo and hi, so with no automatic bins left the
// cross has one bin (19.11.2). Sampling 1 then 2 covers t12 and sel; if the
// first value were used, no bin of tp would intersect {2} and sel would have
// no value, so its 1/1 could not appear. Sampling 3 then 2 covers t32.

module test_cg_transition_binsof_last_value;
  bit [1:0] v;
  bit b;

  covergroup cg;
    tp: coverpoint v {
      bins t12 = (1 => 2);
      bins t32 = (3 => 2);
    }
    cb: coverpoint b { bins lo = {0}; bins hi = {1}; }
    X: cross tp, cb {
      bins sel = binsof(tp) intersect {2};
    }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] vv, bit bb);
    int c, t;
    v = vv;
    b = bb;
    g.sample();
    void'(g.X.get_inst_coverage(c, t));
    $display("(%0d,%0d): x %0d/%0d", vv, bb, c, t);
  endtask

  initial begin
    put(1, 0);
    put(2, 0);
    put(3, 1);
    put(2, 1);
  end
endmodule
