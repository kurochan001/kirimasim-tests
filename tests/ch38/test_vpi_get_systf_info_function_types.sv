/*
:name: test_vpi_get_systf_info_function_types
:description: vpi_get_systf_info gives back the sysfunctype, the compiletf and sizetf routines (or NULL where none was given) and the user data registered for sized, sized signed, real and time system functions and for a task with a compiletf routine (IEEE 1800-2023 Section 38.12)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.12 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_systf_info_function_types.c
:expected_stdout: @test_vpi_get_systf_info_function_types.expected
*/
// IEEE 1800-2023 §38.12: vpi_get_systf_info fills an s_vpi_systf_data
// structure, which the application allocates, with the information of a
// user-defined system task or function. §38.37.1: the information registered
// is the type, the sysfunctype of a function (vpiSizedFunc,
// vpiSizedSignedFunc, vpiRealFunc or vpiTimeFunc here), the name, the
// calltf, compiletf and sizetf routines, any of which can be NULL, and the
// user data. The application registers four functions, which the design does
// not call, and $vt_report, which has a compiletf routine; $vt_report reads
// the information of each function from the handle that vpi_register_systf
// returned, and its own through the vpiUserSystf of its call.

module test_vpi_get_systf_info_function_types;
  initial $vt_report;
endmodule
