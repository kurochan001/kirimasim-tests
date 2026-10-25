/*
:name: test_star_timing_control_identifiers_excluded
:description: identifiers that appear in an @* statement only inside a wait condition, a delay or an event control are not in the @* event expression, while the variables the statement reads elsewhere are (IEEE 1800-2023 Section 9.4.2.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_star_timing_control_identifiers_excluded.expected
*/
// IEEE 1800-2023 §9.4.2.2: identifiers that appear only in timing control
// expressions (wait, event or delay) of the statement are not added to the
// event expression of @*.
//
// Three always @* blocks each count their runs and copy one variable:
//   nw: wait (wv) kw = bw;   wv is 1, so the wait passes at once
//   nd: #(dl) kd = bd;       dl is 0
//   ne: @(ei) ke = be;       waits for a change of ei after each run
// wv, dl and ei change first: no block runs. Then bw, bd and be change:
// each block runs once; the last one then waits for ei, which changes once
// more, and ke gets be.
//
// Icarus Verilog 13.0 adds wv, which appears only in the wait condition, to
// the event expression and runs the first block when wv changes. The 5.052
// release of Verilator does not finish this test.

`timescale 1ns/1ns
module test_star_timing_control_identifiers_excluded;
  int wv = 1, dl = 0, ei = 0;
  int bw = 0, bd = 0, be = 0;
  int kw = 0, kd = 0, ke = 0;
  int nw = 0, nd = 0, ne = 0;

  always @* begin
    nw++;
    wait (wv) kw = bw;
  end

  always @* begin
    nd++;
    #(dl) kd = bd;
  end

  always @* begin
    ne++;
    @(ei) ke = be;
  end

  initial begin
    #1 wv = 2;
    dl = 1;
    ei = 1;
    #1 $display("t=%0t timing only: nw=%0d nd=%0d ne=%0d", $time, nw, nd, ne);
    bw = 5;
    bd = 6;
    be = 7;
    #2 $display("t=%0t read:        nw=%0d nd=%0d ne=%0d kw=%0d kd=%0d ke=%0d", $time, nw, nd, ne,
                kw, kd, ke);
    ei = 2;
    #1 $display("t=%0t ei again:    nw=%0d nd=%0d ne=%0d ke=%0d", $time, nw, nd, ne, ke);
  end
endmodule
