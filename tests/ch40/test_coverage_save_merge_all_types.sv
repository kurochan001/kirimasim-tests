/*
:name: test_coverage_save_merge_all_types
:description: For every coverage type, $coverage_save gives NOCOV or ERROR when the design has no such coverage and OK or ERROR when it has some, and a merge of a name saved with OK gives OK (IEEE 1800-2023 Sections 40.3.2.5, 40.3.2.4)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.5 40.3.2.4 40.2.1 40.3.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_save_merge_all_types.expected
*/
// IEEE 1800-2023 §40.2.1: the coverage API is the same for every coverage
// type, so the test makes the same calls for each of the four. §40.3.2.5:
// $coverage_save gives OK when the data were saved, NOCOV when the design has
// no coverage of the type, and ERROR when the save failed; data saved under a
// name are retrieved by $coverage_merge with that name. §40.3.2.1: a check of
// the hierarchy under $root, the whole design, gives NOCOV when no part of it
// has such coverage, and OK or PARTIAL otherwise. §40.3.2.4: $coverage_merge
// gives OK when it found and merged the data. So a save gives NOCOV or ERROR
// without coverage and OK or ERROR with it, and the merge of a name saved with
// OK gives OK. The test merges only such names, as merging a name without
// data is an error, whose report is left to the tool. Which results a tool
// gives depends on its coverage, so the test prints only how they relate.

module test_coverage_save_merge_all_types_unit;
  logic [3:0] p = 0;
endmodule

module test_coverage_save_merge_all_types;
  test_coverage_save_merge_all_types_unit u();

  int check[4], saved[4], merged[4];
  int types[4] = '{`SV_COV_ASSERTION, `SV_COV_FSM_STATE, `SV_COV_STATEMENT, `SV_COV_TOGGLE};
  string names[4] = '{"assertion", "FSM state", "statement", "toggle"};
  string dbs[4] = '{"test_coverage_save_merge_all_types_assertion",
                    "test_coverage_save_merge_all_types_fsm",
                    "test_coverage_save_merge_all_types_statement",
                    "test_coverage_save_merge_all_types_toggle"};

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    #1 u.p = 4'hf;
    #1 u.p = 4'h0;
    #1;
    foreach (types[i]) begin
      check[i] = $coverage_control(`SV_COV_CHECK, types[i], `SV_COV_HIER, $root);
      saved[i] = $coverage_save(types[i], dbs[i]);
      if (saved[i] == `SV_COV_OK)
        merged[i] = $coverage_merge(types[i], dbs[i]);
    end
    foreach (types[i]) begin
      $display("%s: save gives NOCOV or ERROR without coverage, OK or ERROR with: %s", names[i],
               yes_no(check[i] == `SV_COV_NOCOV ? saved[i] inside {`SV_COV_NOCOV, `SV_COV_ERROR}
                      : check[i] inside {`SV_COV_OK, `SV_COV_PARTIAL}
                        && saved[i] inside {`SV_COV_OK, `SV_COV_ERROR}));
      $display("%s: a merge after a save that gave OK gives OK: %s", names[i],
               yes_no(saved[i] != `SV_COV_OK || merged[i] == `SV_COV_OK));
    end
  end
endmodule
