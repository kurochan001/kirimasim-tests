/*
:name: test_vpi_routines_misc_utilities
:description: utility routines of Table 36-9 do what it lists: vpi_get_vlog_info gives the invocation options and the product and version, vpi_compare_objects tells whether two handles refer to the same object, vpi_release_handle releases handles, and vpi_control with vpiFinish ends the simulation (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.17 38.3 38.38 38.4 38.36.2 38.36.3 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_misc_utilities.c
:args: +vt_mode=fast
:expected_stdout: @test_vpi_routines_misc_utilities.expected
*/
// IEEE 1800-2023 §36.11, Table 36-9: vpi_get_vlog_info retrieves the
// invocation information of the tool, vpi_compare_objects compares the
// objects that handles refer to, vpi_release_handle releases a handle and its
// resources, and vpi_control controls the simulation. §38.17: argv has argc
// entries, the first the name of the tool, and product and version are
// strings; it returns 1. §38.3: 1 for two handles of the same object, else
// 0. §38.38: releasing a handle returns 1, also for an iterator not scanned
// to its end, and does not affect the object. §38.4: vpi_control(vpiFinish,
// 0) returns 1 and runs $finish(0) (20.2) when the routine returns.
// The test runs with the plusarg +vt_mode=fast. At the start of simulation
// the application makes the checks. A time callback at 25 (38.36.2) calls
// vpi_control, so the design prints at 10 and 20, and an end of simulation
// callback (38.36.3) prints at 25.
// The run stops at vpi_compare_objects in Verilator 5.052, which does not
// support it.

`timescale 1ns/1ns

module test_vpi_routines_misc_utilities;
  logic [3:0] r = 4'd5;
  logic [3:0] s = 4'd6;
  integer k;

  initial
    for (k = 1; k <= 5; k = k + 1)
      #10 $display("design at %0t: r=%0d s=%0d", $time, r, s);
endmodule
