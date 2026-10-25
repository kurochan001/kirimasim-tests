/*
:name: test_vpi_coverage_cover_sequence
:description: For a cover sequence, vpiAssertSuccessCovered counts every match, so one attempt can give several successes and the in-progress equation of 40.5.2 does not apply (IEEE 1800-2023 Section 40.5.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.5.2 40.5.1 40.3.2.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_coverage_cover_sequence.c
:expected_stdout: @test_vpi_coverage_cover_sequence.expected
*/
// IEEE 1800-2023 §40.5.2: for a cover sequence, vpiAssertSuccessCovered is the
// number of times the sequence has been matched, and the number of attempts
// still in progress cannot be derived from the counts because one attempt can
// have several matches. §16.14.3: a cover sequence reports all matches of an
// attempt, and its pass statement runs once for each of them. The clock rises
// at 5, 15, 25 and 35, so the cover sequence on ##[1:2] on is attempted four
// times; its endpoints are the tick after the start and the tick after that,
// which gives matches at 15 (from 5), 25 (from 5 and 15) and 35 (from 15
// and 25), five in all. So the pass statement runs five times, the successes
// are five, and they outnumber the four attempts. The counts are read at 40.
// The cover sequence has one coverable entity, so vpiCoveredMax is 1, and it is
// covered as it was attempted and matched. A tool that collects no assertion
// coverage is left out of the checks of the counts, but never of the maximum.

`timescale 1ns/1ns

module test_vpi_coverage_cover_sequence;
  logic clk = 0;
  bit on = 1'b1;
  int hits = 0, started;

  always #5 clk = ~clk;

  c_seq: cover sequence (@(posedge clk) on ##[1:2] on) hits++;

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_HIER,
                               test_vpi_coverage_cover_sequence);
    #40 $vt_cov(started, hits);
    $display("cover matches: %0d", hits);
    $finish;
  end
endmodule
