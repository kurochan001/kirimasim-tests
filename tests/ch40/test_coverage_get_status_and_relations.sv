/*
:name: test_coverage_get_status_and_relations
:description: $coverage_get_max and $coverage_get return SV_COV_ERROR for an unknown coverage type and never for a known one, the maximum stays constant during the simulation, the current coverage does not decrease, and a positive current coverage is not above the maximum (IEEE 1800-2023 Sections 40.3.2.2 and 40.3.2.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.2 40.3.2.3 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_get_status_and_relations.expected
*/
// IEEE 1800-2023 §40.3.2.2: $coverage_get_max returns the number that is 100%
// coverage, which "shall remain constant across the duration of the
// simulation", or 0 when that coverage type is not available, or -1 for an
// error, typically an incorrect argument. §40.3.2.3: $coverage_get returns the
// number of coverable items that have been covered, with the same status
// values, and a percentage is the current value divided by the maximum. The
// current number of covered items cannot fall as the simulation goes on,
// because a covered item stays covered.
//
// The test queries the statement coverage of the module coverage_work by its
// module definition name, twice for the maximum and at two times for the
// current value, and prints whether each relation holds rather than the values
// themselves, because the numbers depend on the coverage the tool supports.
// The calls with coverage type 99 must return -1, which the standard fixes.

`ifndef SV_COV_START
`define SV_COV_START 0
`define SV_COV_STOP 1
`define SV_COV_RESET 2
`define SV_COV_CHECK 3
`define SV_COV_MODULE 10
`define SV_COV_HIER 11
`define SV_COV_ASSERTION 20
`define SV_COV_FSM_STATE 21
`define SV_COV_STATEMENT 22
`define SV_COV_TOGGLE 23
`define SV_COV_OVERFLOW -2
`define SV_COV_ERROR -1
`define SV_COV_NOCOV 0
`define SV_COV_OK 1
`define SV_COV_PARTIAL 2
`endif

module coverage_work;
  int a = 0;

  initial begin
    a = 1;
    a = 2;
  end
endmodule

module test_coverage_get_status_and_relations;
  int maximum, maximum_again, current, later;

  initial begin
    #1;
    maximum = $coverage_get_max(`SV_COV_STATEMENT, `SV_COV_HIER, "coverage_work");
    current = $coverage_get(`SV_COV_STATEMENT, `SV_COV_HIER, "coverage_work");
    maximum_again = $coverage_get_max(`SV_COV_STATEMENT, `SV_COV_HIER, "coverage_work");
    #1 later = $coverage_get(`SV_COV_STATEMENT, `SV_COV_HIER, "coverage_work");
    $display("maximum is not an error: %0d", maximum != `SV_COV_ERROR);
    $display("current is not an error: %0d", current != `SV_COV_ERROR);
    $display("maximum constant: %0d", maximum == maximum_again);
    $display("current below maximum or none: %0d",
             (maximum <= 0) || (current <= maximum));
    $display("current does not decrease: %0d", later >= current);
    $display("invalid type in get_max: %0d",
             $coverage_get_max(99, `SV_COV_HIER, "coverage_work") == `SV_COV_ERROR);
    $display("invalid type in get: %0d",
             $coverage_get(99, `SV_COV_HIER, "coverage_work") == `SV_COV_ERROR);
  end
endmodule
