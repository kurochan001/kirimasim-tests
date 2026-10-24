/*
:name: test_vpi_userdata_failures
:description: vpi_put_userdata takes a call handle and a void pointer and returns 1 when it associates the pointer with that call and 0 when the handle is not a call of a user-defined system task or function; vpi_get_userdata returns the pointer of that call, and NULL for a call without one and when it fails (IEEE 1800-2023 Sections 38.33 and 38.14)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.33 38.14 38.37.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_userdata_failures.c
:expected_stdout: @test_vpi_userdata_failures.expected
*/
// IEEE 1800-2023 §38.33: vpi_put_userdata(vpiHandle obj, void *userdata)
// returns a PLI_INT32: 1 when it has associated userdata with the call of a
// user-defined system task or function that obj refers to, 0 when it fails.
// §38.14: vpi_get_userdata(vpiHandle obj) returns the void * associated with
// that call by an earlier vpi_put_userdata, and NULL when there is none or
// when the routine fails. The application checks the declarations at compile
// time (C11 _Generic in C, decltype in C++). $vt_keep(n) is called from two
// places; at the first run of each it stores a pointer to its own counter
// for that place, and every run prints the counter it gets back. $vt_misuse
// passes the handle of the variable v, which is not a call, to both
// routines, and asks for the user data of its own call, which has none.
// Icarus Verilog 13.0 stops with an assertion in vpi_get_userdata for the
// handle of a variable.

module test_vpi_userdata_failures;
  int v, k;

  initial begin
    for (k = 0; k < 2; k++) begin
      $vt_keep(1);
      $vt_keep(2);
    end
    $vt_misuse(v);
  end
endmodule
