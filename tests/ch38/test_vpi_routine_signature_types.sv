/*
:name: test_vpi_routine_signature_types
:description: The VPI routines have the names and the argument lists of their clauses, which a comparison of their function types observes (IEEE 1800-2023 Section 38.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.1 38.6 38.7 38.11 38.23 38.34 38.36.1 38.36.2 38.38
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routine_signature_types.c
:expected_stdout: @test_vpi_routine_signature_types.expected
*/
// IEEE 1800-2023 §38.1: each routine has a fixed name and a fixed list of
// arguments in a fixed order, and all arguments are required unless the
// clause says otherwise. The type of the address of each routine therefore
// determines both its result type and the types and order of its arguments,
// which a C or C++ type comparison can decide at compile time. The test
// compares the address of each routine with the type that its clause gives:
// vpi_get, vpi_get64, vpi_get_str, vpi_iterate, vpi_scan, vpi_free_object,
// vpi_release_handle, vpi_get_value, vpi_put_value, vpi_register_cb,
// vpi_remove_cb, vpi_control, vpi_printf and vpi_put_delays. Each line prints
// 1 when the type is the one of the clause. The release 13.0 of Icarus
// Verilog declares vpi_printf with a const char * format, so the expected
// output follows the clauses alone.

module test_vpi_routine_signature_types;
  initial begin
    #1 $vt_types;
    $finish;
  end
endmodule
