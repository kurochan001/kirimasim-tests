/*
:name: test_coverage_save_merge
:description: $coverage_save gives OK, NOCOV or ERROR, data saved under a name can be merged back by that name, saving again under the same name is not an error, saving does not change the coverage, and merging a name that was never saved gives an error (IEEE 1800-2023 Sections 40.3.2.4 and 40.3.2.5)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.4 40.3.2.5 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_save_merge.expected
*/
// IEEE 1800-2023 §40.3.2.5: $coverage_save gives SV_COV_OK when it saved the
// data, SV_COV_NOCOV when the design has no coverage of that type, so nothing
// was saved, and SV_COV_ERROR when the save failed, in which case the entry for
// the name is removed. Saving under an existing name is not an error, and
// saving does not change the coverage of the simulation: the toggle coverage
// is the same before and after, with no signal changing in between (40.3.2.3).
// §40.3.2.4: $coverage_merge finds the data by the name used to save it and
// gives SV_COV_OK when it merged data of the requested type; a name with no
// data gives SV_COV_ERROR. Which of these results a tool gives depends on its
// coverage, so the test prints only how they relate. The tool may store the
// data in files named after the given names, in the current directory or
// elsewhere.

module test_coverage_save_merge;
  logic [3:0] d = 0;
  int cov_before, cov_after, saved, saved_again, merged, missing;

  task automatic expect_ok(string what, bit ok);
    if (ok)
      $display("%s", what);
    else
      $display("%s: wrong; saved %0d then %0d, merged %0d, missing %0d, toggle %0d then %0d",
               what, saved, saved_again, merged, missing, cov_before, cov_after);
  endtask

  initial begin
    #1 d = 4'b0101;
    #1 d = 4'b1010;
    #1;
    cov_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_save_merge);
    saved = $coverage_save(`SV_COV_TOGGLE, "test_coverage_save_merge_db");
    cov_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_save_merge);
    saved_again = $coverage_save(`SV_COV_TOGGLE, "test_coverage_save_merge_db");
    merged = $coverage_merge(`SV_COV_TOGGLE, "test_coverage_save_merge_db");
    missing = $coverage_merge(`SV_COV_TOGGLE, "test_coverage_save_merge_never_saved");

    expect_ok("save gives OK, NOCOV or ERROR",
              saved inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_ERROR});
    expect_ok("saving does not change the toggle coverage", cov_after == cov_before);
    expect_ok("saving again under the same name gives the same result", saved_again == saved);
    expect_ok("merge after a successful save gives OK",
              saved != `SV_COV_OK || merged == `SV_COV_OK);
    expect_ok("merge after a failed save gives ERROR",
              saved != `SV_COV_ERROR || merged == `SV_COV_ERROR);
    expect_ok("merge of a name never saved gives ERROR", missing == `SV_COV_ERROR);
  end
endmodule
