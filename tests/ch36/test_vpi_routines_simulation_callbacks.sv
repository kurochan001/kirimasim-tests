/*
:name: test_vpi_routines_simulation_callbacks
:description: the routines of Table 36-1 do what it lists: vpi_register_cb registers value change, time and end of simulation callbacks that then run, vpi_get_cb_info gives back the reason, routine, object and user data of a registered callback, and vpi_remove_cb removes one so that it runs no more (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.36 38.36.1 38.36.2 38.36.3 38.8 38.39
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_simulation_callbacks.c
:expected_stdout: @test_vpi_routines_simulation_callbacks.expected
*/
// IEEE 1800-2023 §36.11, Table 36-1: vpi_register_cb registers a
// simulation-related callback, vpi_remove_cb removes one, and vpi_get_cb_info
// gets the information of one; Clause 38 gives the details. §38.36: the
// application gives the reason, routine, object, time and value formats and
// user data in an s_cb_data structure, and the routine gets them back when it
// is called; a cbValueChange callback (38.36.1) runs after each change of its
// object, a cbAfterDelay callback (38.36.2) after the delay, and a
// cbEndOfSimulation callback (38.36.3) at the end. §38.8: vpi_get_cb_info
// fills an s_cb_data structure with the information of the callback.
// §38.39: vpi_remove_cb returns 1 on success, and the callback is gone.
// At the start of simulation the application registers two value change
// callbacks on r, keep and drop, a time callback 15 later and an end of
// simulation callback, and prints what vpi_get_cb_info gives for drop. The
// time callback removes drop, so drop sees only the change at 10 and keep
// sees all three. The value change routines only record, since the order of
// the two callbacks of one change is not fixed; the end callback prints.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 has vpi_get_cb_info. With
// that call left out, Icarus Verilog gives the rest of the output, and the
// other release also gives the value change callbacks the time 0 instead of
// the time of the change.

`timescale 1ns/1ns

module test_vpi_routines_simulation_callbacks;
  bit [3:0] r;

  initial begin
    #10 r = 4'd1;
    #10 r = 4'd2;
    #10 r = 4'd3;
    #10 $display("design: r=%0d at %0t", r, $time);
  end
endmodule
