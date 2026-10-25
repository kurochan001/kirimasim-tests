/*
:name: test_vpi_user_h_macro_linkage_types
:description: vpi_user.h offers the sized integer types with their widths, defines the DLL import and export qualifiers for the platform, wraps its declarations in C linkage, expands the prototype macros for the routines, and declares vpi_free_object, vpi_release_handle and the external vlog_startup_routines array as Annex K gives them (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_macro_linkage_types.c
:expected_stdout: @test_vpi_user_h_macro_linkage_types.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h. K.2 makes
// the size-critical integer types available through the platform's own
// header, gives the import and export qualifiers PLI_DLLISPEC and
// PLI_DLLESPEC, wraps every declaration in C linkage when compiled as C++,
// declares the routines through the external and prototype macros so that
// their parameter lists expand, keeps vpi_free_object beside
// vpi_release_handle, and declares vlog_startup_routines as an exported array
// of void (void) function pointers whose last element is null.
//
// The C file is compiled as C and, under one runner, as C++. At the start of
// simulation (a cbStartOfSimulation callback, 38.36.3) it calls vpi_printf,
// which only links from C++ when the declarations have C linkage, compares
// the type of a pointer to each named routine with the function pointer type
// made from its K.2 declaration at compile time (C11 _Generic in C, decltype
// in C++), compares the startup array with its definition, and checks the
// DLL qualifiers the header left. A wrong width, parameter list, storage
// class or qualifier prints 0; a missing C linkage stops the C++ build
// before the line is printed.

module test_vpi_user_h_macro_linkage_types;
  initial $finish;
endmodule
