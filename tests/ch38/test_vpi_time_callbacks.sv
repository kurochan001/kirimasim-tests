/*
:name: test_vpi_time_callbacks
:description: cbAfterDelay runs before the events of its time step and cbReadOnlySynch after them, including nonblocking assignments, and cbEndOfSimulation runs when the simulation ends (IEEE 1800-2023 Section 38.36.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.2 38.36.3 38.13 4.4.2.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_time_callbacks.c
:expected_stdout: @test_vpi_time_callbacks.expected
*/
// IEEE 1800-2023 §38.36.2: a cbAfterDelay callback runs after the given delay,
// before the events of that time step, and a cbReadOnlySynch callback after
// them (the Postponed region, 4.4.2.9), when nonblocking assignments have been
// done. §38.36.3: cbEndOfSimulation runs at the end of the simulation. At time
// 0, $vt_schedule registers the two time callbacks with a delay of 10 and the
// end callback. At 10, r is set to 1 by a blocking and then to 2 by a
// nonblocking assignment. vpi_get_time(NULL) gives the time in the simulation
// time unit, here 1 ns (38.13).

`timescale 1ns/1ns

module test_vpi_time_callbacks;
  reg [7:0] r;

  initial begin
    r = 0;
    $vt_schedule(r);
    #10 r = 1;
    r <= 2;
    #10 $finish;
  end
endmodule
