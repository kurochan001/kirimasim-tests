/*
:name: test_vpi_user_h_macro_cleanup
:description: vpi_user.h removes the application's PLI_EXTERN, PLI_VEXTERN, PLI_PROTOTYPES, PROTO_PARAMS, XXTERN and EETERN after its declarations and keeps the application's PLI_DLLISPEC and PLI_DLLESPEC (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_macro_cleanup.c
:expected_stdout: @test_vpi_user_h_macro_cleanup.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h. K.2 ends the
// header with a cleanup: it removes PLI_EXTERN and PLI_VEXTERN, and, when it
// set up the prototype helpers, also PLI_PROTOTYPES, PROTO_PARAMS, XXTERN and
// EETERN. The import and export qualifiers are removed only when the header
// itself gave them their platform value; qualifiers that the application
// supplied are kept.
//
// The C file defines every one of these macros before it includes the
// header, so that the cleanup has a definition to remove and the
// application's qualifiers have something to keep, and the declarations
// still expand. At the start of simulation (a cbStartOfSimulation callback,
// 38.36.3) it prints 1 for each macro that the header removed and for each
// qualifier that it kept, and for the absence of the two cleanup flags that
// only mark a header-supplied qualifier. A header that forgets an #undef, or
// removes an application qualifier, prints 0.

module test_vpi_user_h_macro_cleanup;
  initial $finish;
endmodule
