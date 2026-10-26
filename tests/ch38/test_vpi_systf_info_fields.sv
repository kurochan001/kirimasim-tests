/*
:name: test_vpi_systf_info_fields
:description: vpi_get_systf_info returns the type, sysfunctype, $name, calltf, compiletf, sizetf and user data of registered system tasks and functions, sizetf only for sized functions, in the s_vpi_systf_data structure of the listed field types and order (IEEE 1800-2023 Section 38.12)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.12 38.37.1 38.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_info_fields.c
:expected_stdout: @test_vpi_systf_info_fields.expected
*/
// IEEE 1800-2023 §38.12: vpi_get_systf_info fills an s_vpi_systf_data
// structure that the application allocates with the information of a system
// task or function callback. The structure has a PLI_INT32 type and
// sysfunctype, a PLI_BYTE8* tfname whose first character is $, the calltf,
// compiletf and sizetf routines, each PLI_INT32 (*)(PLI_BYTE8*), and a
// PLI_BYTE8* user_data, in that order; sizetf belongs to sized function
// callbacks only. The type tells a task from a function, and the sysfunctype
// tells vpiIntFunc, vpiRealFunc, vpiTimeFunc, vpiSizedFunc and
// vpiSizedSignedFunc apart.
//
// At the start of the simulation the application registers a task with all
// three routines and functions of the five sysfunctype values, the sized ones
// with a sizetf, then reads each handle that vpi_register_systf returned back
// with vpi_get_systf_info and prints what it got, in registration order. It
// also prints the compile-time checks of the field types and order.

module test_vpi_systf_info_fields;
  initial begin
    #2 $finish;
  end
endmodule
