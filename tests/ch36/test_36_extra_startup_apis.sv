/*
:name: test_36_extra_startup_apis
:description: During vlog_startup_routines only vpi_register_systf and vpi_register_cb are called, and both registrations take effect: the design calls the registered task and the callbacks run (IEEE 1800-2023 Section 36.10.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.2 36.9.1 38.37.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_36_extra_startup_apis.c
:expected_stdout: @test_36_extra_startup_apis.expected
*/
// IEEE 1800-2023 §36.10.2, §38.37.2: the tool calls each routine of
// vlog_startup_routines once, and during that call an application may call
// vpi_register_systf and vpi_register_cb, and no other VPI routine. The
// startup routine here calls those two routines only: it registers the task
// $vt_from_startup and the cbEndOfCompile and cbStartOfSimulation callbacks.
// §38.36.3: cbEndOfCompile comes when the design is built, then
// cbStartOfSimulation at the start of the time 0 cycle. The design calls the
// registered task in its initial procedure. The expected output shows both
// registrations working: the two callbacks run in that order and the task
// prints its line when the design calls it.

module test_36_extra_startup_apis;
  initial $vt_from_startup;
endmodule
