/*
:name: test_cg_excluded_transitions
:description: An ignored or illegal transition removes every transition bin sequence that contains it, the bins left empty are not counted, and an ignored value does not remove a transition that goes through it (IEEE 1800-2023 Sections 19.5.5, 19.5.6)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.5 19.5.6 19.5.2 19.11.1 19.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_excluded_transitions.expected
*/
// IEEE 1800-2023 §19.5.5, §19.5.6: a sequence of a transition bin that cannot
// be matched without also matching an ignored or an illegal sequence is
// removed from the bin, and a bin left with no value or sequence is not
// counted (19.11.1). The ignored 1 => 3 thus empties t_long, the illegal
// 0 => 6 empties t_mid, and the ignored value 7 empties v[7], but an ignored
// value has no effect on a transition, so t_val, 0 => 7, stays. The coverpoint
// keeps v[5], v[6], t_ok and t_val, 4 bins. The test prints the coverage of
// the covergroup, that of its only coverpoint (19.11), after each group of
// samples. It never samples 0 followed by 6, which would be a run-time error.
//
// Version 5.052 of Verilator removes no sequence or value: it keeps all 7 bins
// and counts t_long and v[7] as covered; Icarus Verilog 13.0 does not compile
// covergroups.

module test_cg_excluded_transitions;
  bit [2:0] a;

  covergroup cg;
    cp: coverpoint a {
      bins v[] = {[5:7]};
      bins t_long = (2 => 1 => 3 => 4);
      bins t_mid = (4 => 0 => 6);
      bins t_ok = (5 => 6);
      bins t_val = (0 => 7);
      ignore_bins ig_t = (1 => 3);
      illegal_bins bad_t = (0 => 6);
      ignore_bins ig_v = {7};
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
    run('{2, 1, 3, 4}, "2, 1, 3, 4");
    run('{5}, "then 5");
    run('{6}, "then 6");
    run('{7}, "then 7");
    run('{0, 7}, "then 0, 7");
  end
endmodule
