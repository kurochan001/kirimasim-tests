/*
:name: test_vpi_systf_registration_fields
:description: A registration with vpi_register_systf gives a $ name, a task or function type, a compiletf that runs while the design is compiled and a calltf that runs at each call, and the user data passed to both (IEEE 1800-2023 Sections 36.9 and 36.9.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.9 36.9.1 36.8.2 36.8.3 36.8.4 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_registration_fields.c
:expected_stdout: @test_vpi_systf_registration_fields.expected
*/
// IEEE 1800-2023 §36.9: registering a system task or function associates a
// name with the application routines to call and with data, for calls while
// the source is compiled and while the simulation runs. §36.9.1: through
// vpi_register_systf the application gives the name, which begins with $,
// the C routines and when they are called, whether the name is a task or a
// function, which returns a value, and a data argument passed to the
// routines at each call. The application registers the task $vt_mark, with a
// compiletf and a calltf and the string "task data" as its data, and the
// function $vt_val, with only a calltf and a pointer to the number 41 as its
// data. compiletf records whether it runs before cbStartOfSimulation (36.8.2)
// and with the registered data; calltf of $vt_mark prints the time and its
// data at each call (36.8.3); $vt_val returns its data plus 1. $vt_report
// prints what compiletf recorded.

`timescale 1ns/1ns

module test_vpi_systf_registration_fields;
  initial begin
    $vt_mark;
    #3 $vt_mark;
    $display("$vt_val = %0d", $vt_val);
    $vt_report;
  end
endmodule
