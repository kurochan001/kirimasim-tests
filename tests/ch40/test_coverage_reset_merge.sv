/*
:name: test_coverage_reset_merge
:description: After $coverage_save and a reset of one instance, $coverage_merge loads the saved data back, so the current value of the instance returns to what it was before the reset and merging the same data again does not change it (IEEE 1800-2023 Sections 40.3.2.4 and 40.3.2.5)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.4 40.3.2.5 40.3.2.1 40.3.2.2 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_reset_merge.expected
*/
// IEEE 1800-2023 §40.3.2.5: $coverage_save stores the current coverage under a
// name and does not change the coverage of the simulation. §40.3.2.1: a reset
// clears the available coverage of the hierarchy it names. §40.3.2.4:
// $coverage_merge loads the data saved under the name and merges it, so merging
// data saved from this simulation into the cleared coverage of the instance
// gives back the coverage that was saved, and merging it again changes
// nothing. §40.3.2.2: the maximum does not change during the simulation. The
// coverage is read for the instance u only, whose signals do not change while
// the test makes its calls, so the variables that hold the results, which are
// in the top module, cannot add to it. Which items have coverage depends on the
// tool, so each line prints a relation that holds also when the tool has no
// toggle coverage: without a save that gave OK, the two equalities are vacuous.

`timescale 1ns/1ns

module test_coverage_reset_merge_leaf(input logic [3:0] d);
  logic [3:0] t = 4'h0;

  always_comb t = d;
endmodule

module test_coverage_reset_merge;
  logic [3:0] d = 4'h0;

  test_coverage_reset_merge_leaf u(.d(d));

  int old_value, after, again, max_before, max_after;
  int saved, reset_done, merged, merged_again;

  task automatic show(string what, bit ok);
    if (ok)
      $display("%s: 1", what);
    else
      $display("%s: 0", what);
  endtask

  initial begin
    #1 d = 4'b0101;
    #1 d = 4'b1010;
    #1;
    old_value = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    max_before = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    saved = $coverage_save(`SV_COV_TOGGLE, "test_coverage_reset_merge_db");
    reset_done = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_HIER, u);
    merged = $coverage_merge(`SV_COV_TOGGLE, "test_coverage_reset_merge_db");
    after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    max_after = $coverage_get_max(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    merged_again = $coverage_merge(`SV_COV_TOGGLE, "test_coverage_reset_merge_db");
    again = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);

    show("reset gives OK", reset_done == `SV_COV_OK);
    show("maximum unchanged by reset and merge", max_after == max_before);
    show("a merge after a save that gave OK gives OK",
         saved != `SV_COV_OK || merged == `SV_COV_OK);
    show("merged saved coverage restores the current value",
         saved != `SV_COV_OK || merged != `SV_COV_OK || after == old_value);
    show("merging the same data again keeps the value",
         merged != `SV_COV_OK || merged_again != `SV_COV_OK || again == after);
  end
endmodule
