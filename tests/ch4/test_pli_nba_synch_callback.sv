/*
:name: test_pli_nba_synch_callback
:description: A cbNBASynch callback runs in the Pre-NBA region, after the blocking assignments of its time step and before the nonblocking updates (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 4.4.3.3 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_nba_synch_callback.c
:expected_stdout: @test_pli_nba_synch_callback.expected
*/
// IEEE 1800-2023 §4.10, Table 4-1, §4.4.3.3, §38.36.2: a callback for
// cbNBASynch runs in the Pre-NBA region, just before the nonblocking updates
// are processed. $vt_register, called at 0, registers one for time 10 and one
// for cbReadOnlySynch, in the Postponed region of the same time step. At 10
// the design sets a with a blocking assignment and b with a nonblocking one,
// and the update of b schedules the nonblocking update of c. The cbNBASynch
// callback sees a = 1 and b and c still 0; the cbReadOnlySynch callback sees
// all three set. The design prints nothing at 10.

`timescale 1ns/1ns

module test_pli_nba_synch_callback;
  int a = 0, b = 0, c = 0;

  always @(b) c <= b;

  initial begin
    $vt_register;
    #10;
    a = 1;
    b <= 1;
    #10 $finish;
  end
endmodule
