/*
:name: test_cg_cross_illegal_excluded
:description: Cross products selected by illegal_bins are excluded from the coverage of the cross, so covering the other products gives 100 percent (IEEE 1800-2023 Section 19.6.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.3 19.6.1 19.11.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_illegal_excluded.expected
*/
// IEEE 1800-2023 §19.6.3: the cross products that an illegal_bins select
// expression selects, here <a1, b1>, are excluded from coverage. The cross of
// two coverpoints with two bins each then has three products (19.6.1), and
// the coverage of the cross (19.11.2) grows by a third with each of them. The
// test never samples the illegal product, which would be a run-time error.

module test_cg_cross_illegal_excluded;
  bit [1:0] a, b;

  covergroup cg;
    ca: coverpoint a { bins a0 = {0}; bins a1 = {1}; }
    cb: coverpoint b { bins b0 = {0}; bins b1 = {1}; }
    ab: cross ca, cb {
      illegal_bins both_one = binsof(ca.a1) && binsof(cb.b1);
    }
  endgroup

  cg g = new();

  task automatic put(bit [1:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
    $display("a=%0d b=%0d: cross %0.2f", a, b, g.ab.get_inst_coverage());
  endtask

  initial begin
    put(0, 0);
    put(0, 1);
    put(1, 0);
  end
endmodule
