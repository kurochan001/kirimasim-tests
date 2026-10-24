/*
:name: test_vpi_chk_error_pli_error_callback
:description: After a VPI call that fails, vpi_chk_error returns nonzero and fills in the error information, after one that succeeds it returns 0, and a cbPLIError callback registered at startup is called for the failed call (IEEE 1800-2023 Section 36.10.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.1 36.10.2 38.2 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_chk_error_pli_error_callback.c
:expected_stdout: @test_vpi_chk_error_pli_error_callback.expected
*/
// IEEE 1800-2023 §36.10.1: vpi_chk_error returns a nonzero value when the
// previously called VPI routine had an error, and can give detailed
// information about it (38.2); callbacks can also be set up for when an error
// occurs. §38.36.3: a cbPLIError callback is called when a run-time error
// occurs in a PLI function call, and §36.10.2 allows its registration from a
// startup routine. The startup routine registers cbPLIError and a
// cbStartOfSimulation callback, which registers a cbAfterDelay callback with
// the time type vpiSuppressTime, an error for a simulation time callback
// (38.36.2), checks vpi_chk_error and its s_vpi_error_info, makes a
// vpi_get_time that succeeds and checks vpi_chk_error again; it prints only
// after these checks, since vpi_printf is a VPI call too. The cbPLIError
// callback only records that it ran. The results are printed when the
// simulation ends. The vpi_user.h of Icarus Verilog 13.0 lacks cbPLIError,
// and Verilator 5.052 accepts the registration without an error.

module test_vpi_chk_error_pli_error_callback;
  initial #1;
endmodule
