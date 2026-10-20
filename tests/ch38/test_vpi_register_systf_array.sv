/*
:name: test_vpi_register_systf_array
:description: vlog_startup_routines can list several routines, and a routine can register system tasks and functions from a static array of s_vpi_systf_data ended by a zero entry (IEEE 1800-2023 Section 38.37.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37.3 38.37.2 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_register_systf_array.c
:expected_stdout: @test_vpi_register_systf_array.expected
*/
// IEEE 1800-2023 §38.37.2: the routines in the NULL-terminated array
// vlog_startup_routines are called when the simulator starts, so that they
// register system tasks and functions (38.37.1). §38.37.3: one way to register
// several is a static array of s_vpi_systf_data structures, registered in a
// loop that stops at an entry of 0. The array here has two routines; the
// second registers a task and two functions from such an array.

module test_vpi_register_systf_array;
  initial begin
    $vt_hello;
    $vt_listed;
    $display("$vt_add3(4)=%0d $vt_twice(5)=%0d", $vt_add3(4), $vt_twice(5));
  end
endmodule
