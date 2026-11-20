/*
:name: test_cg_real_coverpoint_cross
:description: A cross may include a coverpoint of a real expression; its cross bins are the products of the interval bins of the real coverpoint with the bins of an integral coverpoint, and the default bin of the real coverpoint and values outside the integral bins add no cross product (IEEE 1800-2023 Sections 19.6, 19.5, 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.5 19.5.1 19.11.2 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_real_coverpoint_cross.expected
*/
// IEEE 1800-2023 §19.6: a cross may include coverpoints of real expressions,
// and its bins are the Cartesian product of the bins of the crossed
// coverpoints. §19.5: coverage of a real expression is limited to value bins
// and their crosses; a default bin counts for neither the coverage of its
// coverpoint nor a cross. §19.5.1: [0.0:2.0] in lo[] of a real coverpoint is
// divided into [0.0:1.0) and [1.0:2.0] with the default interval 1.0.
// §19.11.2: the coverage of a cross without user-defined cross bins is the
// covered products over the product of the numbers of bins. get_inst_coverage
// (c, t) gives the covered bins and the bins (§19.8).
//
// cr has the 2 bins of lo[] and the default other; ck has v[0] and v[1]; the
// cross x has 4 products. The samples (r, k) are (0.5, 0), then (5.0, 1),
// where r falls into the default bin, then (1.0, 1), (1.5, 3), where k has no
// bin, and (0.0, 1); only the first, third and fifth add a product.
// Icarus Verilog 13.0 does not support covergroups, and the 5.054 release
// of the simulator named Verilator does not support the arguments of
// get_inst_coverage; with the percentages instead, it gives the real
// coverpoint 3 bins and does not count 0.5, so the
// expected output follows the cited clauses.

module test_cg_real_coverpoint_cross;
  real r;
  bit [1:0] k;

  covergroup cg;
    cr: coverpoint r { bins lo[] = {[0.0:2.0]}; bins other = default; }
    ck: coverpoint k { bins v[] = {[0:1]}; }
    x: cross cr, ck;
  endgroup

  cg g = new;

  task automatic put(real rv, bit [1:0] kv);
    int c[3], t[3];
    r = rv;
    k = kv;
    g.sample();
    void'(g.cr.get_inst_coverage(c[0], t[0]));
    void'(g.ck.get_inst_coverage(c[1], t[1]));
    void'(g.x.get_inst_coverage(c[2], t[2]));
    $display("r=%.1f k=%0d: cr %0d/%0d, ck %0d/%0d, x %0d/%0d", rv, kv, c[0], t[0], c[1], t[1],
             c[2], t[2]);
  endtask

  initial begin
    put(0.5, 0);
    put(5.0, 1);
    put(1.0, 1);
    put(1.5, 3);
    put(0.0, 1);
  end
endmodule
