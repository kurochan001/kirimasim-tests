/*
:name: test_vpi_coverage_control
:description: vpi_control with vpiCoverageReset and vpiCoverageStop resets and stops coverage of an instance as $coverage_control does, which $coverage_get then shows (IEEE 1800-2023 Section 40.5.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.3 40.5.1 40.3.2.1 40.3.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_control.c
:expected_stdout: @test_vpi_coverage_control.expected
*/
// IEEE 1800-2023 §40.5.3: vpi_control(<coverageControl>, <coverageType>,
// instance_handle) controls coverage with the semantics of $coverage_control
// (40.3.2.1); the controls and types are the constants of 40.5.1. $vt_cov
// calls it with vpiToggleCoverage for this instance. After vpiCoverageReset,
// before any signal changes, $coverage_get (40.3.2.3) of the instance gives
// zero; after vpiCoverageStop, the bits of t toggling do not raise it. This
// holds whether or not the tool collects toggle coverage, as NOCOV is zero.

module test_vpi_coverage_control;
  logic [7:0] t = 8'h00;
  int value0, value1;

  initial begin
    t = 8'hff;
    t = 8'h00;
    $vt_cov("reset");
    $display("toggle coverage right after vpiCoverageReset: %0d",
             $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, test_vpi_coverage_control));
    $vt_cov("stop");
    value0 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, test_vpi_coverage_control);
    t = 8'hff;
    t = 8'h00;
    value1 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_MODULE, test_vpi_coverage_control);
    $display("toggle coverage unchanged after vpiCoverageStop: %s",
             value1 == value0 ? "yes" : "no");
  end
endmodule
