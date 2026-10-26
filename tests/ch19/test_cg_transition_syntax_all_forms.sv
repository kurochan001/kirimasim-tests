/*
:name: test_cg_transition_syntax_all_forms
:description: transition bins are built from ordered trans_list alternatives, range-list items, consecutive, goto and nonconsecutive repetitions, an open array of transitions and an iff, and each becomes one bin unless it is declared with [] (IEEE 1800-2023 Section 19.5.2)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.2 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_transition_syntax_all_forms.expected
*/
// IEEE 1800-2023 §19.5.2, Syntax 19-3: a bins declaration of a trans_list is a
// transition bin. A trans_list is one or more trans_set items separated by
// commas, and a trans_set is a list of trans_range_list items joined by =>.
// A trans_range_list item is a value or a range list item (a, b => c), and a
// repetition is [* n] for n consecutive occurrences, [-> n] for a goto
// repetition and [= n] for a nonconsecutive repetition. With [] the
// declaration gives one bin for each transition of the list. A transition bin
// may have an iff, which guards its coverage. §19.11.1: the coverage of the
// point is the covered bins over all bins. The test declares seven bins, then
// samples one transition for each form and prints the coverage after each
// group of samples; the guarded bin stays uncovered while en is 0.

module test_cg_transition_syntax_all_forms;
  bit [2:0] v;
  bit en;

  covergroup cg;
    cp: coverpoint v {
      bins alt[] = (1 => 2, 3 => 4);
      bins rep = (1 [* 2] => 3);
      bins go = (1 => 2 [-> 1]);
      bins noncon = (1 => 2 [= 1]);
      bins rng = (1, 2 => 3, 4);
      bins guard = (5 => 6) iff (en);
    }
  endgroup

  cg g = new;

  task automatic put(bit [2:0] x);
    v = x;
    g.sample();
  endtask

  initial begin
    en = 0;
    put(1); put(2);
    $display("1,2 (alt[0], go, noncon): %0.2f", g.get_inst_coverage());
    put(3);
    $display("then 3 (rng 2=>3): %0.2f", g.get_inst_coverage());
    put(4);
    $display("then 4 (alt[1]): %0.2f", g.get_inst_coverage());
    put(1); put(1); put(3);
    $display("then 1,1,3 (rep): %0.2f", g.get_inst_coverage());
    put(2); put(4);
    $display("then 2,4 (no new bin): %0.2f", g.get_inst_coverage());
    put(5); put(6);
    $display("then 5,6 with en=0: %0.2f", g.get_inst_coverage());
    en = 1;
    put(5); put(6);
    $display("then 5,6 with en=1: %0.2f", g.get_inst_coverage());
  end
endmodule
