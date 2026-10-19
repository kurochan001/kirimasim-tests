/*
:name: test_cg_illegal_bins_removed
:description: The values of illegal_bins are removed from the other bins, and a bin left empty is not counted (IEEE 1800-2023 Section 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.6 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_illegal_bins_removed.expected
*/
// IEEE 1800-2023 §19.5.6: the values of illegal_bins are excluded from coverage:
// after the values are given to the bins, each illegal value is taken out of
// every other bin. bins b[] = {[0:3]} with 3 illegal leaves b[3] empty, and an
// empty bin is not counted (19.11.1), so the coverpoint has 3 bins. The test
// never samples the illegal value, which would be a run-time error.
//
// Version 5.052 of Verilator keeps b[3] and counts 4 bins; Icarus Verilog 13.0
// does not compile covergroups.

module test_cg_illegal_bins_removed;
  bit [1:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins b[] = {[0:3]};
      illegal_bins bad = {3};
    }
  endgroup

  cg inst;

  initial begin
    inst = new;
    a = 0; inst.sample();
    $display("after 0: %0.2f", inst.get_inst_coverage());
    a = 1; inst.sample();
    a = 2; inst.sample();
    $display("after 1 and 2: %0.2f", inst.get_inst_coverage());
  end
endmodule
