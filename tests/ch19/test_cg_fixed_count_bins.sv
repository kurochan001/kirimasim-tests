/*
:name: test_cg_fixed_count_bins
:description: bins b[N] shares the listed values out among N bins, the last bin taking the remainder (IEEE 1800-2023 Section 19.5.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.1 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_fixed_count_bins.expected
*/
// IEEE 1800-2023 §19.5.1: bins b[3] = {[0:7]} makes exactly 3 bins and shares
// the 8 values out evenly among them, the last bin taking the values left over:
// <0,1>, <2,3> and <4,5,6,7>. So 4 and 7 cover the same bin, and 1 and 2 cover
// different ones.
//
// Version 5.052 of Verilator ignores the count and makes one bin per value;
// Icarus Verilog 13.0 does not compile covergroups.

module test_cg_fixed_count_bins;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a { bins b[3] = {[0:7]}; }
  endgroup

  cg inst;

  initial begin
    inst = new;
    a = 4; inst.sample();
    a = 7; inst.sample();
    $display("after 4 and 7: %0.2f", inst.get_inst_coverage());
    a = 1; inst.sample();
    $display("after 1: %0.2f", inst.get_inst_coverage());
    a = 2; inst.sample();
    $display("after 2: %0.2f", inst.get_inst_coverage());
  end
endmodule
