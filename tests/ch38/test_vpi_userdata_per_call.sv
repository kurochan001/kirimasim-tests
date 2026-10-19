/*
:name: test_vpi_userdata_per_call
:description: vpi_put_userdata and vpi_get_userdata keep data for each call of a user-defined system task, and calltf receives the user_data given at registration (IEEE 1800-2023 Section 38.33)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.33 38.14 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_userdata_per_call.c
:expected_stdout: @test_vpi_userdata_per_call.expected
*/
// IEEE 1800-2023 §38.33, §38.14: vpi_put_userdata stores a pointer with one
// call of a user-defined system task (a vpiSysTfCall handle), and
// vpi_get_userdata returns it, or NULL if nothing was stored. Each of the three
// calls of $vt_tick in the source therefore counts its own executions, however
// often a loop runs it. §38.37.1: the user_data field given to
// vpi_register_systf is the argument of every calltf call.

module test_vpi_userdata_per_call;
  integer k;

  initial begin
    for (k = 0; k < 3; k = k + 1) $vt_tick("loop A");
    for (k = 0; k < 2; k = k + 1) $vt_tick("loop B");
    $vt_tick("single call");
  end
endmodule
