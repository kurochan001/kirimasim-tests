/*
:name: test_vpi_coverage_save_merge
:description: vpi_control with vpiCoverageSave saves coverage under a name as $coverage_save does, and with vpiCoverageMerge merges saved coverage as $coverage_merge does, so each finds what the other saved (IEEE 1800-2023 Section 40.5.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.3 40.5.1 40.3.2.4 40.3.2.5 40.3.2.1 40.3.2.3 38.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_save_merge.c
:expected_stdout: @test_vpi_coverage_save_merge.expected
*/
// IEEE 1800-2023 §40.5.3: vpi_control(vpiCoverageSave, <coverage type>, name)
// saves the coverage of the simulation with the semantics of $coverage_save
// (40.3.2.5), and vpi_control(vpiCoverageMerge, <coverage type>, name) merges
// with the semantics of $coverage_merge (40.3.2.4); the constants are those of
// 40.5.1. §38.4: vpi_control returns 1 when it succeeds and 0 when it fails.
// The functions $vt_cov_save and $vt_cov_merge make these calls with
// vpiToggleCoverage and return what vpi_control returns.
//
// Saving does not change the coverage, so the toggle coverage of u
// (40.3.2.3) is the same before and after the save through VPI, and data saved
// that way can be merged with $coverage_merge by its name. Data saved with
// $coverage_save, merged through VPI after a reset of u (40.3.2.1), gives back
// the value from before the reset. A name that was never saved cannot be
// merged, which is an error, so vpi_control fails. Whether a tool has toggle
// coverage depends on the tool, so the merges are checked only where a check
// of u gives SV_COV_OK and the save succeeded.

`timescale 1ns/1ns

module test_vpi_coverage_save_merge_unit;
  logic [3:0] t = 4'h0;
endmodule

module test_vpi_coverage_save_merge;
  test_vpi_coverage_save_merge_unit u();

  int check, value, after_save, vpi_saved, merged, saved, reset_done, vpi_merged, restored;
  int missing;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    #1 u.t = 4'hf;
    #1 u.t = 4'h0;
    #1;
    check = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_HIER, u);
    value = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    vpi_saved = $vt_cov_save("test_vpi_coverage_save_merge_vpi");
    after_save = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    merged = $coverage_merge(`SV_COV_TOGGLE, "test_vpi_coverage_save_merge_vpi");
    saved = $coverage_save(`SV_COV_TOGGLE, "test_vpi_coverage_save_merge_sv");
    reset_done = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_HIER, u);
    vpi_merged = $vt_cov_merge("test_vpi_coverage_save_merge_sv");
    restored = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, u);
    missing = $vt_cov_merge("test_vpi_coverage_save_merge_never_saved");
    $display("saving through vpiCoverageSave leaves the coverage unchanged: %s",
             yes_no(after_save == value));
    $display("data saved through vpiCoverageSave is merged by $coverage_merge: %s",
             yes_no(check != `SV_COV_OK || vpi_saved != 1 || merged == `SV_COV_OK));
    $display("vpiCoverageMerge of data saved by $coverage_save restores the value: %s",
             yes_no(check != `SV_COV_OK || saved != `SV_COV_OK
                    || (reset_done == `SV_COV_OK && vpi_merged == 1 && restored == value)));
    $display("vpiCoverageMerge of a name never saved fails: %s", yes_no(missing == 0));
  end
endmodule
