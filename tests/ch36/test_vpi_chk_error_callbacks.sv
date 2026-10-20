/*
:name: test_vpi_chk_error_callbacks
:description: vpi_chk_error reports an error after a simulation time callback that the standard forbids, such as one with no time or a zero-delay cbReadWriteSynch at read-only synch time, and 0 after a call that succeeds (IEEE 1800-2023 Section 36.10.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.1 38.2 38.36.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_chk_error_callbacks.c
:expected_stdout: @test_vpi_chk_error_callbacks.expected
*/
// IEEE 1800-2023 §36.10.1, §38.2: vpi_chk_error returns a nonzero severity
// when the previous VPI call failed and 0 otherwise, and calling it does not
// change that status. §38.36.2 makes these calls errors that create no
// callback: a simulation time callback without a time structure, a
// cbAtStartOfSimTime with delay 0 once the time slice has begun, outside such
// a callback, and a cbReadWriteSynch with delay 0 at read-only synch time.
// $vt_try makes the first two calls and a valid cbReadOnlySynch registration
// at 5; the cbReadOnlySynch callback makes the third one.

`timescale 1ns/1ns

module test_vpi_chk_error_callbacks;
  initial #5 $vt_try;
endmodule
