/*
:name: test_vpi_userdata_compiletf
:description: vpi_put_userdata returns 1 and can store data with each call of a system function from its compiletf routine, which calltf then reads back; a later vpi_put_userdata replaces the stored data, and a call that stored nothing gets NULL (IEEE 1800-2023 Sections 38.33 and 38.14)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.33 38.14 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_userdata_compiletf.c
:expected_stdout: @test_vpi_userdata_compiletf.expected
*/
// IEEE 1800-2023 §38.33: vpi_put_userdata associates a value with a call of a
// user-defined system task or function and returns 1 on success. §38.14:
// vpi_get_userdata returns the value of the last such association, or NULL
// if there was none. §38.37.1: compiletf is called for each call in the source
// when the design is compiled, before the simulation. The compiletf routine of
// the function $vt_seq gives each of its two calls a counter of its own, which
// calltf increments and returns, so the call in the loop returns 3 at its
// third run and the other 1. Each run of $vt_mark reads what the previous run
// stored and replaces it; $vt_peek never stores anything.

module test_vpi_userdata_compiletf;
  int a, b, k;

  initial begin
    for (k = 0; k < 3; k++) a = $vt_seq();
    b = $vt_seq();
    $display("a=%0d b=%0d", a, b);
    repeat (3) $vt_mark;
    $vt_peek;
  end
endmodule
