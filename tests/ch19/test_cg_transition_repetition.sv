/*
:name: test_cg_transition_repetition
:description: Transition bins with consecutive, goto and nonconsecutive repetition are covered only by the sequences of samples the repetition describes, and an array of transition bins has one bin per transition (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.2 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_transition_repetition.expected
*/
// IEEE 1800-2023 §19.5.2: 5 [* 3] is three successive samples of 5. In
// 6 => 1 [-> 2] => 3, the two 1s may be preceded by other values, but the 3
// has to come right after the second 1. In 7 => 2 [= 2] => 4, other values may
// also come between the second 2 and the 4, as long as no further 2 does. The
// array arr[] has a bin for each of the transitions 0 => 6 and 4 => 6. The
// coverpoint has 5 bins (19.11.1), and the test prints its coverage after each
// group of samples: first ones that come close to a bin without matching it,
// then ones that match it.

module test_cg_transition_repetition;
  bit [2:0] v;

  covergroup cg;
    cp: coverpoint v {
      bins rep = (5 [* 3]);
      bins gto = (6 => 1 [-> 2] => 3);
      bins ncr = (7 => 2 [= 2] => 4);
      bins arr[] = (0, 4 => 6);
    }
  endgroup

  cg inst = new();

  task automatic run(int vals[$], string what);
    foreach (vals[i]) begin
      v = vals[i];
      inst.sample();
    end
    $display("%s: %.2f", what, inst.get_inst_coverage());
  endtask

  initial begin
    run('{5, 5, 4, 5, 5}, "5, 5, 4, 5, 5");
    run('{5}, "then 5");
    run('{6, 1, 1, 2, 3}, "then 6, 1, 1, 2, 3");
    run('{6, 1, 0, 1, 3}, "then 6, 1, 0, 1, 3");
    run('{7, 2, 0, 2, 2, 4}, "then 7, 2, 0, 2, 2, 4");
    run('{7, 2, 1, 2, 0, 4}, "then 7, 2, 1, 2, 0, 4");
    run('{0, 6}, "then 0, 6");
    run('{4, 6}, "then 4, 6");
  end
endmodule
