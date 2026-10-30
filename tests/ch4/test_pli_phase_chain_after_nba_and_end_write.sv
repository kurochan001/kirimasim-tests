/*
:name: test_pli_phase_chain_after_nba_and_end_write
:description: PLI callbacks capture a Pre-Active write through NBA and observe the end-of-time write and its HDL reaction in read-only, without fixing read-write synch before or after NBA (IEEE 1800-2023 Section 4.4.3.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.2 4.4.3.9 4.4.3.10 4.10 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_phase_chain_after_nba_and_end_write.c
:expected_stdout: @test_pli_phase_chain_after_nba_and_end_write.expected
*/
// IEEE 1800-2023 4.10, Table 4-1, and 38.36.2: cbAfterDelay writes value
// in Pre-Active, before HDL captures it through NBA. cbReadWriteSynch may
// run before or after NBA, so it only records that it ran. cbAtEndOfSimTime
// writes another value in Pre-Postponed; the resulting HDL reaction settles
// before cbReadOnlySynch in Postponed. Only there are the captured value,
// read-write callback count and settled values observed (4.4.3.2/.9/.10).
// Oracle checks: The 5.052 release does not build this case.

`timescale 1ns/1ns
module test_pli_phase_chain_after_nba_and_end_write;
  int value, captured, reacted;
  always @(value) reacted = value + 1;
  initial begin
    $depth_install;
    #5 captured <= value;
    #2 $finish;
  end
endmodule
