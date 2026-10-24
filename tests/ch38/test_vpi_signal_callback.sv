/*
:name: test_vpi_signal_callback
:description: A cbSignal callback registered with the index set to an operating system signal is called when that signal occurs, the simulator trapping the signal instead of ending, with the reason cbSignal and its user_data (IEEE 1800-2023 Section 38.36.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.3 38.36
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_signal_callback.c
:expected_stdout: @test_vpi_signal_callback.expected
*/
// IEEE 1800-2023 §38.36.3: cbSignal is one of the action callbacks that every
// VPI tool has, for a signal that occurs. To set up a signal handler with
// vpi_register_cb, the reason is cbSignal and the index field is one of the
// signals of the operating system; when the signal occurs, the simulator traps
// it, goes on to a safe point if it can, and then calls the callback routine,
// which gets an s_cb_data with the reason (38.36).
//
// At the start of the simulation, a cbStartOfSimulation callback registers a
// cbSignal callback for SIGTERM, a signal of the C library, with user_data
// "term" (a startup routine may place only the reasons of 36.10.2). At 1,
// $vt_raise raises SIGTERM with the C function raise, but only when the
// registration gave a handle, so that a tool without the callback does not end
// here. Without a handler SIGTERM would end the process; with it, the
// simulation goes on, and at 5 $vt_check prints how often the callback ran and
// what it got. The design prints a line at 3, after the signal.

`timescale 1ns/1ns

module test_vpi_signal_callback;
  initial begin
    #1 $vt_raise;
    #2 $display("%0t: the simulation goes on after the signal", $time);
    #2 $vt_check;
  end
endmodule
