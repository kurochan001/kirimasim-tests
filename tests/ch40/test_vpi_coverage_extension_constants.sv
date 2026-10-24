/*
:name: test_vpi_coverage_extension_constants
:description: sv_vpi_user.h defines each coverage control, coverage type property, coverage status property, assertion coverage status property and FSM handle type constant that the coverage extension of VPI adds, with the value of Annex M, and the controls and the properties are distinct (IEEE 1800-2023 Section 40.5.1, M.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.1 M.2 36.7 38.36.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_extension_constants.c
:expected_stdout: @test_vpi_coverage_extension_constants.expected
*/
// IEEE 1800-2023 §40.5.1: the coverage extension of VPI adds the coverage
// controls vpiCoverageStart, Stop, Reset, Check, Merge and Save; the coverage
// type properties vpiAssertCoverage, vpiFsmStateCoverage,
// vpiStatementCoverage and vpiToggleCoverage; the coverage status properties
// vpiCovered and vpiCoveredCount; the assertion coverage status properties
// vpiAssertAttemptCovered, SuccessCovered, FailureCovered,
// VacuousSuccessCovered, DisableCovered and KillCovered; and the FSM handle
// type vpiFsmHandle. M.2: sv_vpi_user.h (§36.7) defines them as integer
// constants with fixed values.
//
// At the start of the simulation (a cbStartOfSimulation callback, 38.36.3) the
// VPI application prints the group, name and value of each constant that the
// header defines; a constant that is missing is a missing line, and one that
// is not an integer constant does not compile. It then prints 1 when the six
// controls are all defined and all different, and when the twelve coverage
// properties, which vpi_get takes, are all defined and all different.

module test_vpi_coverage_extension_constants;
endmodule
