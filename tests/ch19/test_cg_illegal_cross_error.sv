/*
:name: test_cg_illegal_cross_error
:description: Illegal cross products are excluded from cross coverage and a sampled illegal cross product issues a run-time error even when it is also in an ordinary cross bin or an ignored bin (IEEE 1800-2023 Section 19.6.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.3 19.6.1 19.11.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_illegal_cross_error.expected
:expected_stderr_regex: test_cg_illegal_cross_error\.sv:68:
*/
// IEEE 1800-2023 §19.6.3: all cross products selected by an illegal_bins
// select expression are excluded from coverage and their occurrence issues a
// run-time error. Illegal cross products take precedence over other cross
// products: <1,1> is in the ordinary bin both, in the ignored bin ig and in
// illegal_bins bad, and it still causes the error. In covergroup ex the
// ignored product <0,0> and the illegal product <0,1> are never sampled; the
// two remaining products <1,0> and <1,1> are the only bins, so ex is 2/2 and
// 100.00. Covergroup cg first samples <0,1> (ignored) and <1,0> (automatic)
// without an error, prints a marker, and then samples <1,1>.

module test_cg_illegal_cross_error;
  bit [1:0] a, b;

  covergroup ex;
    ca: coverpoint a { bins v[] = {[0:1]}; }
    cb: coverpoint b { bins v[] = {[0:1]}; }
    X: cross ca, cb {
      ignore_bins ig = binsof(ca) intersect {0} && binsof(cb) intersect {0};
      illegal_bins bad = binsof(ca) intersect {0} && binsof(cb) intersect {1};
    }
  endgroup

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:1]}; }
    cb: coverpoint b { bins v[] = {[0:1]}; }
    X: cross ca, cb {
      bins both = binsof(ca) intersect {1} && binsof(cb) intersect {1};
      ignore_bins ig = binsof(cb) intersect {1};
      illegal_bins bad = binsof(ca) intersect {1} && binsof(cb) intersect {1};
    }
  endgroup

  ex e = new;
  cg g = new;

  initial begin
    int c, t;
    a = 1;
    b = 0;
    e.sample();
    a = 1;
    b = 1;
    e.sample();
    void'(e.X.get_inst_coverage(c, t));
    $display("ex %0d/%0d %.2f", c, t, e.X.get_inst_coverage());
    a = 0;
    b = 1;
    g.sample();
    a = 1;
    b = 0;
    g.sample();
    $display("before illegal");
    a = 1;
    b = 1;
    g.sample();
  end
endmodule
