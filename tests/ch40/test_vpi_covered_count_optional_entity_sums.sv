/*
:name: test_vpi_covered_count_optional_entity_sums
:description: Available statement and signal hit counts sum their constituent entities and tools may leave these counts unavailable
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.2.2 40.3.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_covered_count_optional_entity_sums.c
:expected_stdout: @test_vpi_covered_count_optional_entity_sums.expected
*/
// The two statements run twice. Signal bits 0 and 1 toggle, while
// bit 2 stays at zero. If provided, hit counts must sum across each
// block or signal. +observe_optional_counts also prints the raw values.
`timescale 1ns/1ns
module test_vpi_covered_count_optional_entity_sums;
  logic [2:0] signal_bits = 0;
  int a = 0, b = 0;
  bit verbose;
  int statement_started, toggle_started;

  task automatic steps();
    a = a + 1;
    b = b + 2;
  endtask

  initial begin
    verbose = $test$plusargs("observe_optional_counts");
    statement_started = $coverage_control(`SV_COV_START, `SV_COV_STATEMENT, `SV_COV_MODULE,
                                          test_vpi_covered_count_optional_entity_sums);
    toggle_started = $coverage_control(`SV_COV_START, `SV_COV_TOGGLE, `SV_COV_MODULE,
                                       test_vpi_covered_count_optional_entity_sums);
    #1 signal_bits = 3'b011;
    steps();
    #1 signal_bits = 0;
    steps();
    #1 signal_bits = 3'b001;
    #1 signal_bits = 0;
    #1 $display("hdl statements=%0d,%0d signal=%b", a, b, signal_bits);
  end
endmodule
