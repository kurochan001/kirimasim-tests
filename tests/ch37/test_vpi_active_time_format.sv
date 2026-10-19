/*
:name: test_vpi_active_time_format
:description: vpi_handle(vpiActiveTimeFormat, NULL) is NULL until $timeformat has been called and then is the system task call of the $timeformat in effect, whose arguments can be read (IEEE 1800-2023 Section 37.82)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.82 37.42 20.4.3 38.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_active_time_format.c
:expected_stdout: @test_vpi_active_time_format.expected
*/
// IEEE 1800-2023 §37.82: vpi_handle(vpiActiveTimeFormat, NULL) returns the
// task call of the $timeformat (§20.4.3) in effect, and NULL if $timeformat
// has not been called (detail 1). The call is a system task call (§37.42)
// named $timeformat; vpi_iterate(vpiArgument, call) gives its arguments, read
// with vpi_get_value (§38.15). After the second $timeformat the handle is
// that call.

module test_vpi_active_time_format;
  initial begin
    $vt_format;
    $timeformat(-9, 2, " ns", 12);
    $vt_format;
    $timeformat(-6, 1, "us", 8);
    $vt_format;
  end
endmodule
