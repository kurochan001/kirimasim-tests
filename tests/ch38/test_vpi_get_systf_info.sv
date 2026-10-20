/*
:name: test_vpi_get_systf_info
:description: vpi_get_systf_info fills an s_vpi_systf_data structure with what was registered for a user-defined system task or function, from the handle that registration returned or the vpiUserSystf of a call (IEEE 1800-2023 Section 38.12)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.12 38.37 37.42
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_systf_info.c
:expected_stdout: @test_vpi_get_systf_info.expected
*/
// IEEE 1800-2023 §38.12: vpi_get_systf_info returns, in a structure that the
// application provides, the information of a system task or function
// callback: its type, sysfunctype, name, routines and user data, as given to
// vpi_register_systf (38.37), which returns the handle. The handle can also be
// reached from a call with vpiUserSystf (37.42). The application registers
// $vt_info, a task, and $vt_twice, an integer function, and compares.

module test_vpi_get_systf_info;
  initial begin
    $vt_info;
    $display("twice: %0d", $vt_twice(21));
  end
endmodule
