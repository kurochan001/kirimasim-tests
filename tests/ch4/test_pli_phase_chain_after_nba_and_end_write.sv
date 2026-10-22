/*
:name: test_pli_phase_chain_after_nba_and_end_write
:description: PLI phase callbacks observe successive NBA and end of time writes before a read only final observation (IEEE 1800-2023 Section 4.4.3.2)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.2 4.4.3.4 4.4.3.9 4.4.3.10 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_phase_chain_after_nba_and_end_write.c
:expected_stdout: @test_pli_phase_chain_after_nba_and_end_write.expected
*/
// IEEE 1800-2023 4.4.3.2 4.4.3.4 4.4.3.9 4.4.3.10 38.36.2: A pre-active
// callback writes one value before HDL saves it through NBA; post-NBA sees that
// copy, end-of-time writes another value, and read-only sees its HDL reaction.
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
