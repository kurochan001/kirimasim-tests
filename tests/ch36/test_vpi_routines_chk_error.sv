/*
:name: test_vpi_routines_chk_error
:description: the routine vpi_chk_error of Table 36-9 does what it lists: after a VPI call that fails it returns a severity level of Table 38-1 and describes the error in its structure, and after a call that succeeds it returns 0 (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.2 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_chk_error.c
:expected_stdout: @test_vpi_routines_chk_error.expected
*/
// IEEE 1800-2023 §36.11, Table 36-9: vpi_chk_error retrieves the error
// status and details of the preceding VPI call. §38.2: it returns one of the
// levels vpiNotice to vpiInternal of Table 38-1 when that call resulted in an
// error, with the same level in the s_vpi_error_info structure, and 0 when it
// did not; every VPI call other than vpi_chk_error resets the status.
// §38.36.2: registering a cbAfterDelay callback without a time structure is
// an error, and no callback is made.
// At the start of simulation the application registers such a callback and
// calls vpi_chk_error, then calls vpi_get_time, which succeeds, and calls
// vpi_chk_error again; it prints after both checks, since vpi_printf is a
// VPI call too. The design prints at time 1.
// Icarus Verilog 13.0 reports the failed registration in a message, but its
// vpi_chk_error returns 0; Verilator 5.052 makes no error of it.

module test_vpi_routines_chk_error;
  initial #1 $display("design: done");
endmodule
