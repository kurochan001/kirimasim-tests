/*
:name: test_cg_auto_bins_max
:description: Automatic bins of a coverpoint: one per value up to auto_bin_max, and values shared out with the rest in the last bin above it (IEEE 1800-2023 Section 19.5.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.3 19.7 19.11.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_auto_bins_max.expected
*/
// IEEE 1800-2023 §19.5.3: a coverpoint with no bins of its own gets automatic
// bins, MIN(2**M, auto_bin_max) of them, where M is the number of bits. With the
// default auto_bin_max of 64 (19.7), a 2-bit coverpoint has 4 bins. With
// auto_bin_max = 3, the 8 values of a 3-bit coverpoint go into <0,1>, <2,3>
// and <4,5,6,7>, the last bin taking the remainder. §19.11.1: coverage is the
// number of covered bins divided by that number of bins.

module test_cg_auto_bins_max;
  bit [1:0] p;
  bit [2:0] a;

  covergroup cg_default;
    coverpoint p;
  endgroup

  covergroup cg_max3;
    coverpoint a { option.auto_bin_max = 3; }
  endgroup

  cg_default i_def;
  cg_max3 i_max;

  initial begin
    i_def = new;
    i_max = new;
    p = 2; i_def.sample();
    $display("2-bit, default auto_bin_max, after 2: %0.2f", i_def.get_inst_coverage());
    a = 4; i_max.sample();
    a = 7; i_max.sample();
    $display("auto_bin_max 3, after 4 and 7 (same bin): %0.2f", i_max.get_inst_coverage());
    a = 2; i_max.sample();
    $display("after 2: %0.2f", i_max.get_inst_coverage());
    a = 3; i_max.sample();
    $display("after 3 (same bin as 2): %0.2f", i_max.get_inst_coverage());
    a = 1; i_max.sample();
    $display("after 1: %0.2f", i_max.get_inst_coverage());
  end
endmodule
