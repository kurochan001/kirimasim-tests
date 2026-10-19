/*
:name: test_cg_cross_coverage
:description: A cross of two coverpoints has one bin per pair of their bins, and counts as one more item in the covergroup average (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.11.2 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_coverage.expected
*/
// IEEE 1800-2023 §19.6: cross cpp, cpq makes a bin for each pair of a bin of
// cpp and a bin of cpq, so two coverpoints of 2 bins make 4 cross bins, and a
// sample covers the pair of bins its values fall in. §19.11.2: the coverage of
// the cross is the number of covered pairs divided by 4. §19.11: the covergroup
// averages the coverage of cpp, cpq and the cross.
//
// Version 5.052 of Verilator returns the share of all bins of the covergroup;
// Icarus Verilog 13.0 does not compile covergroups.

module test_cg_cross_coverage;
  bit p, q;

  covergroup cg;
    cpp: coverpoint p { bins p0 = {0}; bins p1 = {1}; }
    cpq: coverpoint q { bins q0 = {0}; bins q1 = {1}; }
    pxq: cross cpp, cpq;
  endgroup

  cg inst;

  initial begin
    inst = new;
    p = 0; q = 0; inst.sample();
    $display("after (0,0): %0.2f", inst.get_inst_coverage());
    p = 1; q = 0; inst.sample();
    $display("after (1,0): %0.2f", inst.get_inst_coverage());
    p = 1; q = 1; inst.sample();
    $display("after (1,1): %0.2f", inst.get_inst_coverage());
    p = 0; q = 1; inst.sample();
    $display("after (0,1): %0.2f", inst.get_inst_coverage());
  end
endmodule
