/*
:name: test_pli_region_callbacks
:description: Simulation time callbacks for one time step run in the PLI regions around the design's events: cbAtStartOfSimTime before the Active region, cbAtEndOfSimTime after the NBA region and cbReadOnlySynch last (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 4.4.3 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_region_callbacks.c
:expected_stdout: @test_pli_region_callbacks.expected
*/
// IEEE 1800-2023 §4.10, Table 4-1, §38.36.2: a callback for cbAtStartOfSimTime
// runs in the Pre-Active region, before the events of its time step; one for
// cbAtEndOfSimTime in the Pre-Postponed region, after the nonblocking updates;
// and one for cbReadOnlySynch in the Postponed region (4.4.3). $vt_register,
// called at 0, registers the three callbacks for time 10, where the design
// sets a with a blocking and b with a nonblocking assignment. Each callback
// prints a and b. The design prints nothing at 10, so the order of the lines
// is that of the regions.

`timescale 1ns/1ns

module test_pli_region_callbacks;
  int a = 0, b = 0;

  initial begin
    $vt_register;
    #10;
    a = 1;
    b <= 1;
    #10 $finish;
  end
endmodule
