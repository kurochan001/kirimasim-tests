/*
:name: test_vpi_simulation_callbacks_dynamic
:description: Simulation callbacks registered with vpi_register_cb call the application when a variable changes value, when a given amount of simulation time has passed and when the simulation ends, each with its reason and user data (IEEE 1800-2023 Sections 36.9 and 36.9.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.9 36.9.2 38.36.1 38.36.2 38.36.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_simulation_callbacks_dynamic.c
:expected_stdout: @test_vpi_simulation_callbacks_dynamic.expected
*/
// IEEE 1800-2023 §36.9: an application can have the simulator call it
// automatically for simulation activities, by registering simulation
// callbacks. §36.9.2: vpi_register_cb requests a call when a specific activity
// occurs, such as a value change, the advance of time or the end of the
// simulation. At the start of the simulation the application registers a
// cbValueChange callback on x (38.36.1), a cbAfterDelay callback for a delay
// of 5 (38.36.2) and a cbEndOfSimulation callback (38.36.3), each with its
// own user data, and each callback prints the time, its reason, its user data
// and, for the value change, the new value. x changes at 2 and 7, and $finish
// ends the simulation at 10.

`timescale 1ns/1ns

module test_vpi_simulation_callbacks_dynamic;
  int x;

  initial begin
    #2 x = 1;
    #5 x = 2;
    #3 $finish;
  end
endmodule
