/*
:name: test_vpi_chk_error_status
:description: After a VPI call that fails, vpi_chk_error returns a severity level of Table 38-1 that its error structure repeats, and the next VPI call that succeeds clears the error status, while vpi_chk_error itself does not (IEEE 1800-2023 Section 36.10.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.1 38.2 38.36.2 36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_chk_error_status.c
:expected_stdout: @test_vpi_chk_error_status.expected
*/
// IEEE 1800-2023 §36.10.1, §38.2: vpi_chk_error returns nonzero, the
// severity level of the error, one of vpiNotice to vpiInternal (Table 38-1),
// when the previous VPI call failed, and 0 when it did not; its
// s_vpi_error_info argument then describes the error, level included. Any VPI
// call other than vpi_chk_error resets the error status. §38.36.2: a
// simulation time callback whose time type is vpiSuppressTime is an error.
// $vt_try registers such a cbAfterDelay callback twice. After the first one,
// it checks the result and the structure, then makes a successful
// vpi_get_time; after the second one, it checks twice and then makes a
// successful vpi_get. It calls vpi_printf only after its checks, since that
// is a VPI call too.
// Icarus Verilog 13.0 prints a message for each failed registration, but its
// vpi_chk_error returns 0 after them.

`timescale 1ns/1ns

module test_vpi_chk_error_status;
  initial #5 $vt_try;
endmodule
