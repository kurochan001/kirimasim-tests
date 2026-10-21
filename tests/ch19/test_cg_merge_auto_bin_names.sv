/*
:name: test_cg_merge_auto_bin_names
:description: With type_option.merge_instances, the automatic bins of instances with different auto_bin_max have different names and add up in the union of the bins, while instances with the same auto_bin_max share theirs (IEEE 1800-2023 Section 19.11.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.11.3 19.5.3 19.7 19.7.1 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_merge_auto_bin_names.expected
*/
// IEEE 1800-2023 §19.11.3: with merge_instances set (19.7.1), the type
// coverage is computed on the union of the bins of all instances, where bins
// with the same name are one bin. Automatic bins are named auto[value] or
// auto[low:high] (19.5.3). With auto_bin_max 8 (19.7), set from the covergroup
// argument, the 3-bit coverpoint has auto[0] to auto[7]; with 4 it has
// auto[0:1] to auto[6:7]. g8a and g8b share their 8 bins, g4 adds 4 others, so
// the type has 12 bins. The test prints the type coverage (19.8) after each
// group of samples; the sample of 1 by g8b covers no new bin.

module test_cg_merge_auto_bin_names;
  bit [2:0] a;

  covergroup cg (int abm);
    type_option.merge_instances = 1;
    option.auto_bin_max = abm;
    cp: coverpoint a;
  endgroup

  cg g8a = new(8);
  cg g4 = new(4);
  cg g8b = new(8);

  task automatic put(int which, bit [2:0] v);
    a = v;
    case (which)
      0: g8a.sample();
      1: g4.sample();
      default: g8b.sample();
    endcase
  endtask

  initial begin
    put(0, 0);
    put(0, 1);
    put(1, 0);
    $display("g8a samples 0 and 1, g4 samples 0: type %.2f", cg::get_coverage());
    put(2, 1);
    $display("then g8b samples 1: type %.2f", cg::get_coverage());
    put(2, 4);
    put(2, 5);
    put(1, 7);
    $display("then g8b samples 4 and 5, g4 samples 7: type %.2f", cg::get_coverage());
  end
endmodule
