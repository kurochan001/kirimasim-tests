/*
:name: test_vpi_end_of_simulation_no_events
:description: When the simulation ends because no events remain, without $finish, the cbEndOfSimulation callback runs at the time of the last event, after the design's last activity; action callbacks registered with only their reason, routine and user_data set run with that reason and user_data (IEEE 1800-2023 Section 38.36.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 38.36 36.9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_end_of_simulation_no_events.c
:expected_stdout: @test_vpi_end_of_simulation_no_events.expected
*/
// IEEE 1800-2023 §38.36.3: cbEndOfSimulation comes when the simulation ends,
// either by $finish or because no more events remain in the event queue; this
// design has no $finish, and its last event is at time 12. cbStartOfSimulation
// comes at the beginning of the time 0 cycle, before the design runs. For
// these action callbacks only reason, cb_rtn and, if wanted, user_data have to
// be set in the s_cb_data structure given to vpi_register_cb (38.36); the
// application sets nothing else (obj, time and value stay NULL), gives
// cbStartOfSimulation no user_data, and gives cbEndOfSimulation "the end".
// Each callback checks the reason and the user_data it gets. The end of
// simulation callback also reads r by name, which keeps its last value.

`timescale 1ns/1ns

module test_vpi_end_of_simulation_no_events;
  logic [3:0] r = 0;

  initial begin
    #5 r = 1;
    #7 r = 2;
    $display("%0t: last activity of the design, r = %0d", $time, r);
  end
endmodule
