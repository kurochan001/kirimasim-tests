/*
:name: test_cg_wildcard_array_and_transition
:description: A wildcard array of bins has a bin for each value its pattern matches, and wildcard transition bins match each transition between values of their patterns, one bin per transition for an array (IEEE 1800-2023 Section 19.5.4)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.4 19.5.2 19.11.1 19.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cg_wildcard_array_and_transition.expected
*/
// IEEE 1800-2023 §19.5.4: in a wildcard bin each ? bit stands for 0 and 1. A
// wildcard array of bins gets a separate bin for each value of the pattern, so
// arr[] = {4'b10?1} is the two bins for 9 and 11. A wildcard transition bin is
// the set of transitions between the values of its patterns (19.5.2), so tr is
// incremented by 0 or 1 followed by 12 or 14, and the array tra[] has the two
// bins 4 => 6 and 5 => 6. The coverpoint has 5 bins (19.11.1), and the test
// prints the coverage of the covergroup, that of its only coverpoint (19.11),
// after each group of samples. 1 followed by 13 does not match tr, as the last
// bit of 13 is 1.

module test_cg_wildcard_array_and_transition;
  bit [3:0] w;

  covergroup cg;
    cp: coverpoint w {
      wildcard bins arr[] = {4'b10?1};
      wildcard bins tr = (4'b000? => 4'b11?0);
      wildcard bins tra[] = (4'b010? => 4'b0110);
    }
  endgroup

  cg inst = new();

  task automatic run(int vals[$], string what);
    foreach (vals[i]) begin
      w = vals[i];
      inst.sample();
    end
    $display("%s: %.2f", what, inst.get_inst_coverage());
  endtask

  initial begin
    run('{9}, "9");
    run('{1, 13}, "then 1, 13");
    run('{0, 14}, "then 0, 14");
    run('{4, 6}, "then 4, 6");
    run('{11}, "then 11");
    run('{5, 6}, "then 5, 6");
  end
endmodule
