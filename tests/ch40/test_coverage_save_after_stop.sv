/*
:name: test_coverage_save_after_stop
:description: Stopping coverage leaves its current value unchanged, and $coverage_save still saves the stopped coverage for merging (IEEE 1800-2023 Sections 40.3.2.1, 40.3.2.4 and 40.3.2.5)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.3 40.3.2.4 40.3.2.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_save_after_stop.expected
*/
// IEEE 1800-2023 §40.3.2.1: a stop with good arguments gives SV_COV_OK and
// stops collecting coverage. §40.3.2.3: the current value of a stopped type
// does not change when a signal then toggles. §40.3.2.5: $coverage_save saves
// the data collected so far, also while coverage is stopped, and the save does
// not change the coverage (§40.3.2.3). §40.3.2.4: merging by the saved name
// gives SV_COV_OK when the save succeeded. The tool may store the data in
// files named after the given name.

`timescale 1ns/1ns

module test_coverage_save_after_stop;
  logic [3:0] d = 0;
  int stopped, value_before, value_after, saved, merged;

  initial begin
    #1 d = 4'b0101;
    #1 d = 4'b1010;
    #1;
    stopped = $coverage_control(`SV_COV_STOP, `SV_COV_TOGGLE, `SV_COV_HIER,
                                test_coverage_save_after_stop);
    value_before = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_save_after_stop);
    #1 d = 4'b1111;
    value_after = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_save_after_stop);
    saved = $coverage_save(`SV_COV_TOGGLE, "test_coverage_save_after_stop_db");
    merged = $coverage_merge(`SV_COV_TOGGLE, "test_coverage_save_after_stop_db");
    $display("stop gives OK: %0d", stopped == `SV_COV_OK);
    $display("stopped coverage does not change: %0d", value_after == value_before);
    $display("save after stop gives OK or NOCOV: %0d",
             saved inside {`SV_COV_OK, `SV_COV_NOCOV});
    $display("merge after save gives OK: %0d",
             saved != `SV_COV_OK || merged == `SV_COV_OK);
  end
endmodule
