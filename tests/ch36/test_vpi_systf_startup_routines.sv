/*
:name: test_vpi_systf_startup_routines
:description: The routines of vlog_startup_routines each run once before the design is compiled, and the system tasks they register are all available, with compiletf running after the last of them (IEEE 1800-2023 Sections 36.3.1, 36.8.2 and 36.9.1)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.1 36.9.1 36.8.2 38.37.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_startup_routines.c
:expected_stdout: @test_vpi_systf_startup_routines.expected
*/
// IEEE 1800-2023 §36.9.1, §38.37.2: the application names the routines that
// register system tasks in the array vlog_startup_routines, which ends with
// a NULL entry, and the tool calls each of them once while it builds the
// design. §36.3.1: every call of vpi_register_systf adds a name to the
// registry. Each of the three routines here registers one task and counts
// how many routines have run. §36.8.2: compiletf runs when the design is
// compiled, after every startup routine has run, which the count it records
// shows.

module test_vpi_systf_startup_routines;
  initial begin
    $vt_probe;
    $vt_one;
    $vt_two;
    $vt_three;
  end
endmodule
