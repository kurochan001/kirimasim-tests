/*
:name: test_vpi_systf_compile_and_call_phases
:description: vpi_register_systf returns a handle to the registered vpiUserSystf object; its compiletf routine runs for each call in the source while the design is built, before the end of compilation, also for a call that never runs, and its calltf routine each time a call is executed, both with the registered user_data (IEEE 1800-2023 Section 38.37, 38.37.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37 38.37.1 38.37.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_compile_and_call_phases.c
:expected_stdout: @test_vpi_systf_compile_and_call_phases.expected
*/
// IEEE 1800-2023 §38.37: vpi_register_systf registers the callbacks of a
// user-defined system task or function, which come when a call of it is met
// while the source is compiled or while it is executed, and returns a handle
// to the callback object. §38.37.1: compiletf runs when the design is compiled
// or built, and calltf each time the task runs during the simulation; routines
// that are not needed, such as sizetf here, are NULL. Each routine gets the
// user_data given at registration.
//
// A startup routine (38.37.2) registers $vt_mark with a compiletf and a
// calltf and keeps the handle, and registers $vt_report with only a calltf.
// $vt_mark appears three times in the source, once in a branch that never
// runs, and runs at 0 and at 3. A cbEndOfCompile callback (38.36.3) marks the
// end of the build, so compiletf can tell whether it ran before it. $vt_report
// prints the type of the handle that registration returned, the name that
// vpi_get_systf_info gives for it, and the counts.

`timescale 1ns/1ns

module test_vpi_systf_compile_and_call_phases;
  initial begin
    $vt_mark;
    #3 $vt_mark;
    if ($time > 100) $vt_mark;
    $vt_report;
  end
endmodule
