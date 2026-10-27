/*
:name: test_vpi_compiletf_sizetf
:description: compiletf runs once for each call site, sizetf once for a sized system function and not for other types, both before the end of compilation, calltf once for each execution, and all three get the registered user_data (IEEE 1800-2023 Section 36.8)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8 36.8.1 36.8.2 36.8.3 36.8.4 36.10.2 38.37.1 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compiletf_sizetf.c
:expected_stdout: @test_vpi_compiletf_sizetf.expected
*/
// IEEE 1800-2023 §36.8.2: compiletf runs once for each call of the system task
// or function in the source: $vt_task appears three times, one of them in a
// branch that never runs, and $vt_wide twice. §36.8.1, §38.37.1: sizetf runs
// at most once, only for a function of type vpiSizedFunc or
// vpiSizedSignedFunc, so not for $vt_int, a vpiIntFunc with a sizetf; the
// function then returns as many bits as sizetf says, 40 for $vt_wide, which
// sets all of them, so w is zero-extended. §36.10.2, §38.37.1: sizetf and
// compiletf run while the design is built, before the cbEndOfCompile callback,
// which comes before cbStartOfSimulation (38.36.3). §36.8.3: calltf runs each
// time the call executes, four times for $vt_task. §36.8.4: each routine gets
// the user_data given at registration. $vt_report prints what the application
// recorded.

module test_vpi_compiletf_sizetf;
  logic [63:0] w, w2;
  integer n;

  initial begin
    repeat (3) $vt_task;
    if (n === 5) $vt_task;
    $vt_task;
    w = $vt_wide;
    w2 = $vt_wide;
    n = $vt_int;
    $display("w = %h, w2 = %h, n = %0d", w, w2, n);
    $vt_report;
  end
endmodule
