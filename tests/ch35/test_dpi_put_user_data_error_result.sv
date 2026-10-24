/*
:name: test_dpi_put_user_data_error_result
:description: svPutUserData returns 0 when it stores a pointer and -1 when the scope or the user data pointer is NULL, and a failed call stores nothing (IEEE 1800-2023 Section 35.5.3, H.9.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.3 H.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_put_user_data_error_result.c
:expected_stdout: @test_dpi_put_user_data_error_result.expected
*/
// IEEE 1800-2023 §35.5.3: a context import has the scope of its declaration.
// H.9.3: svPutUserData stores a user data pointer for a scope and a key; a
// NULL scope or a NULL user data pointer is not allowed, and every such error
// makes it return -1, while success returns 0. svGetUserData gives NULL when
// no pointer was stored for the scope and key.
//
// c_put_errors calls svPutUserData with a NULL user data pointer and with a
// NULL scope, both with the first key, then once correctly with another key,
// and prints each result and what svGetUserData then gives for the import's
// own scope and the two keys: nothing is stored for the first key there, also
// not by the call with a NULL scope.
//
// svPutUserData of Verilator 5.052 returns 0 in every case (see the simulator
// differences document), and Icarus Verilog 13.0 has no DPI, so :oracle:
// names no simulator.

module test_dpi_put_user_data_error_result;
  import "DPI-C" context function void c_put_errors();

  initial c_put_errors();
endmodule
