/*
:name: test_cg_item_weighted_average
:description: The coverage of a covergroup is the average of the coverage of its coverpoints, weighted by their weight options (IEEE 1800-2023 Section 19.11)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11 19.11.1 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_item_weighted_average.expected
*/
// IEEE 1800-2023 §19.11: the coverage of a covergroup is the average of the
// coverage of its items (19.11.1), each multiplied by its weight, which is 1
// unless option.weight sets it (19.7). With one item at 50% and one at 25%, the
// covergroup is at 37.5% with equal weights and at 43.75% with weights 3 and 1;
// it is not the share of all bins taken together (2 of 6, or 33.33%).
//
// Version 5.052 of Verilator returns the share of all bins and ignores the
// weight option; Icarus Verilog 13.0 does not compile covergroups.

module test_cg_item_weighted_average;
  bit p;
  bit [1:0] q;

  covergroup cg_equal;
    c1: coverpoint p { bins b[] = {[0:1]}; }
    c2: coverpoint q { bins b[] = {[0:3]}; }
  endgroup

  covergroup cg_weighted;
    c1: coverpoint p { bins b[] = {[0:1]}; option.weight = 3; }
    c2: coverpoint q { bins b[] = {[0:3]}; option.weight = 1; }
  endgroup

  cg_equal ie;
  cg_weighted iw;

  initial begin
    ie = new;
    iw = new;
    p = 0; q = 0;
    ie.sample();
    iw.sample();
    $display("equal weights: %0.2f", ie.get_inst_coverage());
    $display("weights 3 and 1: %0.2f", iw.get_inst_coverage());
  end
endmodule
