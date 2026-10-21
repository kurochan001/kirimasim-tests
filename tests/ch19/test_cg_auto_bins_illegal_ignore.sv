/*
:name: test_cg_auto_bins_illegal_ignore
:description: A coverpoint with only illegal and ignored bins gets automatic bins, from which the illegal and ignored values are removed after all values have been shared out, and an automatic bin left empty is not counted (IEEE 1800-2023 Sections 19.5.6, 19.5.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.6 19.5.5 19.5.3 19.7 19.11.1 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_auto_bins_illegal_ignore.expected
*/
// IEEE 1800-2023 §19.5.3: a coverpoint that defines no bins other than
// illegal and ignored ones gets automatic bins; with auto_bin_max 5 (19.7) the
// 16 values of a 4-bit coverpoint go 3 to a bin, the last bin taking the rest:
// [0:2], [3:5], [6:8], [9:11] and [12:15]. §19.5.6, §19.5.5: the illegal and
// ignored values are removed after this distribution, so the illegal 3 to 5
// leave [3:5] empty, which is then not counted (19.11.1), and the ignored 12
// and 13 leave 14 and 15 in the last bin. The coverpoint has 4 bins, and
// sampling 0, 1 and 2 covers one of them; had the values been removed first,
// the remaining 11 values would have been shared out over 5 bins. The test
// prints the coverage of the covergroup, that of its only coverpoint (19.11),
// after each group of samples. It never samples an illegal value, which would
// be a run-time error.
//
// Version 5.052 of Verilator keeps the illegal and ignored values in the
// automatic bins, so it counts 5 bins and the samples of 12 and 13; Icarus
// Verilog 13.0 does not compile covergroups.

module test_cg_auto_bins_illegal_ignore;
  bit [3:0] a;

  covergroup cg;
    cp: coverpoint a {
      option.auto_bin_max = 5;
      illegal_bins bad = {[3:5]};
      ignore_bins skip = {12, 13};
    }
  endgroup

  cg inst = new();

  task automatic run(int vals[$], string what);
    foreach (vals[i]) begin
      a = vals[i];
      inst.sample();
    end
    $display("%s: %.2f", what, inst.get_inst_coverage());
  endtask

  initial begin
    run('{0, 1, 2}, "0, 1, 2");
    run('{12, 13}, "then the ignored 12, 13");
    run('{14}, "then 14");
    run('{6}, "then 6");
    run('{11}, "then 11");
  end
endmodule
