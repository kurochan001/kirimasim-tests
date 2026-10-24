/*
:name: test_cg_bin_hit_counts
:description: The count of a value bin grows with every sample of one of its values, and the count of a transition bin with every complete match of its sequence, also for overlapping matches, but at most once per sample (IEEE 1800-2023 Section 19.5)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.2 19.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_bin_hit_counts.expected
*/
// IEEE 1800-2023 §19.5: the count of a bin of a set of values is incremented
// every time the coverpoint matches one of the values, and the count of a bin
// of a sequence of transitions every time the coverpoint matches the entire
// sequence. §19.5.2: a transition bin is incremented for every complete match
// even when matches overlap, but at most once per sample. The counts are seen
// through option.at_least (19.7): a bin is covered once its count reaches it.
// Each covergroup has one coverpoint with one bin.
//
// cg_val: set = {0, [2:3]} with at_least 3. The samples 0, 1, 2 give it the
// count 2 (1 is not in the set), so it is not covered; 3 makes the count 3.
// cg_ovl: (1 => 2 => 1) with at_least 2. 1, 2, 1 match once; with 2, 1 more,
// a second match starts at the third sample, which ended the first one.
// cg_once: (3 => 0), (1 => 3 => 0) with at_least 2. In 1, 3, 0 both
// sequences end at the last sample, which adds 1 to the count only; 3, 0 more
// adds the second.
//
// Version 5.052 of Verilator ignores at_least, so every bin is covered after
// its first hit; Icarus Verilog 13.0 does not compile covergroups.

module test_cg_bin_hit_counts;
  bit [1:0] a;

  covergroup cg_val;
    option.at_least = 3;
    cp: coverpoint a { bins set = {0, [2:3]}; }
  endgroup

  covergroup cg_ovl;
    option.at_least = 2;
    cp: coverpoint a { bins ov = (1 => 2 => 1); }
  endgroup

  covergroup cg_once;
    option.at_least = 2;
    cp: coverpoint a { bins two = (3 => 0), (1 => 3 => 0); }
  endgroup

  cg_val gv = new;
  cg_ovl go = new;
  cg_once gn = new;

  task automatic run(int which, int vals[$]);
    foreach (vals[i]) begin
      a = vals[i];
      case (which)
        0: gv.sample();
        1: go.sample();
        default: gn.sample();
      endcase
    end
  endtask

  initial begin
    run(0, '{0, 1, 2});
    $display("value bin after 0, 1, 2: %.0f", gv.get_inst_coverage());
    run(0, '{3});
    $display("value bin then 3: %.0f", gv.get_inst_coverage());
    run(1, '{1, 2, 1});
    $display("overlap bin after 1, 2, 1: %.0f", go.get_inst_coverage());
    run(1, '{2, 1});
    $display("overlap bin then 2, 1: %.0f", go.get_inst_coverage());
    run(2, '{1, 3, 0});
    $display("two sequences ending together after 1, 3, 0: %.0f", gn.get_inst_coverage());
    run(2, '{3, 0});
    $display("two sequences then 3, 0: %.0f", gn.get_inst_coverage());
  end
endmodule
