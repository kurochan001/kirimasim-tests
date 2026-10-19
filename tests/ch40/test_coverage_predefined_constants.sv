/*
:name: test_coverage_predefined_constants
:description: The predefined coverage macros have the values the standard gives them (IEEE 1800-2023 Section 40.3.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_predefined_constants.expected
*/
// IEEE 1800-2023 §40.3.1: every tool predefines `define macros for the coverage
// controls, the scope definitions, the coverage types and the status results
// used by the coverage system functions. The test prints the value of each.

module test_coverage_predefined_constants;
  initial begin
    $display("control: start %0d, stop %0d, reset %0d, check %0d",
             `SV_COV_START, `SV_COV_STOP, `SV_COV_RESET, `SV_COV_CHECK);
    $display("scope: module %0d, hierarchy %0d", `SV_COV_MODULE, `SV_COV_HIER);
    $display("type: assertion %0d, FSM state %0d, statement %0d, toggle %0d",
             `SV_COV_ASSERTION, `SV_COV_FSM_STATE, `SV_COV_STATEMENT, `SV_COV_TOGGLE);
    $display("status: overflow %0d, error %0d, no coverage %0d, ok %0d, partial %0d",
             `SV_COV_OVERFLOW, `SV_COV_ERROR, `SV_COV_NOCOV, `SV_COV_OK, `SV_COV_PARTIAL);
  end
endmodule
