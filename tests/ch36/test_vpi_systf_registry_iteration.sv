/*
:name: test_vpi_systf_registry_iteration
:description: The names of user-defined system tasks and functions are defined by registering them, from any routine of vlog_startup_routines, and the registry can be listed with vpi_iterate(vpiUserSystf, NULL), which gives the objects that the registrations returned (IEEE 1800-2023 Section 36.3.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.1 36.9.1 37.42 38.37 38.37.2 38.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_registry_iteration.c
:expected_stdout: @test_vpi_systf_registry_iteration.expected
*/
// IEEE 1800-2023 §36.3.1, §36.9.1: the names of user-defined system tasks and
// functions are defined through a registry of callbacks, by calls of
// vpi_register_systf, which returns a handle to the registered object
// (38.37); the routines that make them are placed in vlog_startup_routines
// (38.37.2). §37.42 (detail 6): vpi_iterate with vpiUserSystf and a NULL
// reference gives all user-defined system tasks and functions, and a call of
// one has the property vpiUserDefn (detail 5). The first startup routine
// registers $vt_list and the function $vt_triple, the second one $vt_mark,
// each with the routine's name as user data. $vt_list lists the registered
// objects whose names start with $vt_, sorted by name, with their kind and
// user data (38.12), and compares each with the handle its registration
// returned.

module test_vpi_systf_registry_iteration;
  initial begin
    $display("$vt_triple(14) = %0d", $vt_triple(14));
    $vt_mark;
    $vt_list;
  end
endmodule
