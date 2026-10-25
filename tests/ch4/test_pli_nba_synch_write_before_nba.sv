/*
:name: test_pli_nba_synch_write_before_nba
:description: A cbNBASynch callback in the Pre-NBA region reads values after the Active events and before the nonblocking updates, and a value it writes wakes a design process that runs before those updates (IEEE 1800-2023 Section 4.4.3.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.3.3 4.10 4.5 38.36.2 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_nba_synch_write_before_nba.c
:expected_stdout: @test_pli_nba_synch_write_before_nba.expected
*/
// IEEE 1800-2023 §4.4.3.3: the Pre-NBA region lets a PLI application read and
// write values and create events before the events of the NBA region are
// evaluated. §4.10, Table 4-1: a cbNBASynch callback runs there. §4.5: the
// events of the first nonempty region after Active are moved to the Active
// region, so the process that a callback write wakes runs before the NBA
// region is reached. §38.34: vpiNoDelay writes a value at once.
// $vt_register, called at 0, registers a cbNBASynch and a cbReadOnlySynch
// callback for 10. At 10 the design sets e = 1 and d <= 1. The cbNBASynch
// callback sees e=1 and d=0 and writes x = 8, which wakes the process that
// copies d into d_seen: it still sees d=0. The cbReadOnlySynch callback then
// sees x=8, d_seen=0 and d=1. A callback after the nonblocking updates would
// see d=1, and so would the process it wakes.
// Icarus Verilog 13.0 does not register cbNBASynch callbacks, and the
// release 5.052 of Verilator cannot call a system task that a VPI
// application registers.

`timescale 1ns/1ns

module test_pli_nba_synch_write_before_nba;
  int e = 0, d = 0, x = 0, d_seen = -1;

  always @(x) d_seen = d;

  initial begin
    $vt_register;
    #10;
    e = 1;
    d <= 1;
    #10 $finish;
  end
endmodule
