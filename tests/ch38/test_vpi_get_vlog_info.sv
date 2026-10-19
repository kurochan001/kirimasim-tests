/*
:name: test_vpi_get_vlog_info
:description: vpi_get_vlog_info succeeds and gives the invocation arguments, starting with the tool's name, and product and version strings; vpi_chk_error reports no error after a successful call and leaves the status as it is; vpi_release_handle frees an iterator that was not scanned to its end (IEEE 1800-2023 Sections 38.17, 38.2 and 38.38)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.17 38.2 38.38
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_vlog_info.c
:expected_stdout: @test_vpi_get_vlog_info.expected
*/
// IEEE 1800-2023 §38.17: vpi_get_vlog_info returns 1 on success and fills in
// argc, argv, whose entry 0 is the tool's name, and the product and version
// strings. Their contents depend on the tool, so the application prints only
// whether they are there. §38.2: after a call without an error, vpi_chk_error
// returns 0, and calling it does not change the error status, so a second
// call returns 0 too. §38.38: an iterator left before vpi_scan returns NULL is
// released with vpi_release_handle, which returns 1 on success.

module test_vpi_get_vlog_info;
  logic r1 = 1'b0, r2 = 1'b1;

  initial $vt_info;
endmodule
