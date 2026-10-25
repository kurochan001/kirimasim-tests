/*
:name: test_vpi_routines_systf_and_userdata
:description: the routines of Table 36-2 and the user-data routines of Table 36-9 do what they list: vpi_register_systf registers a system function and a system task that the design then calls, vpi_get_systf_info gives back their registration data, and vpi_put_userdata and vpi_get_userdata keep a value for each call of a system task in the source (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.37 38.37.1 38.12 38.33 38.14
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_systf_and_userdata.c
:expected_stdout: @test_vpi_routines_systf_and_userdata.expected
*/
// IEEE 1800-2023 §36.11: Table 36-2 lists vpi_register_systf to register a
// system task or system function callback and vpi_get_systf_info to get its
// information; Table 36-9 lists vpi_put_userdata and vpi_get_userdata to
// store and get user data in the work area of the VPI. §38.37, §38.37.1: the
// application gives the type, function type, name, routines and user data
// in an s_vpi_systf_data structure, and the calltf runs for each call; a
// system function returns the value its calltf puts on the call handle.
// §38.12: vpi_get_systf_info fills such a structure for the callback handle
// that vpi_register_systf returned. §38.33, §38.14: vpi_put_userdata
// associates a value with a call of a system task in the source and returns
// 1; vpi_get_userdata returns it, or NULL if nothing was stored.
// $vt_sum is a vpiIntFunc that returns the sum of its two arguments. $vt_count
// keeps a counter in the user data of its call: the call in the repeat loop
// runs twice, so its counter reaches 2, while the other call has its own.
// $vt_info prints what vpi_get_systf_info gives for the two registrations.
// The system tasks and functions that a VPI application registers cannot be
// called in Verilator 5.052.

module test_vpi_routines_systf_and_userdata;
  int a, b;

  initial begin
    a = $vt_sum(2, 3);
    b = $vt_sum(10, 20);
    $display("design: a=%0d b=%0d", a, b);
    repeat (2) $vt_count;
    $vt_count;
    $vt_info;
  end
endmodule
