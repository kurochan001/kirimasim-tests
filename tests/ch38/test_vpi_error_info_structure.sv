/*
:name: test_vpi_error_info_structure
:description: vpi_user.h defines s_vpi_error_info with the fields, field types and order of Figure 38-1, the error states vpiCompile, vpiPLI and vpiRun, and the severity levels of Table 38-1 from vpiNotice, the lowest, to vpiInternal, the highest (IEEE 1800-2023 Section 38.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.2 K.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_error_info_structure.c
:expected_stdout: @test_vpi_error_info_structure.expected
*/
// IEEE 1800-2023 §38.2 (Figure 38-1): the s_vpi_error_info structure that
// vpi_chk_error fills has the fields state and level, of type PLI_INT32,
// message, product, code and file, of type PLI_BYTE8 *, and line, of type
// PLI_INT32, in this order; p_vpi_error_info points to it. The state is one
// of vpiCompile, vpiPLI and vpiRun, and the level one of the severity levels
// of Table 38-1, which ranks them from vpiNotice, the lowest, through
// vpiWarning, vpiError and vpiSystem to vpiInternal, the highest. Annex K
// (K.2) gives these constants the values 1 to 3 and 1 to 5.
//
// At the start of the simulation (a cbStartOfSimulation callback, 38.36.3),
// the VPI application prints 1 for each check that holds: a type compared at
// compile time (C11 _Generic in C, decltype in C++) with the type of Figure
// 38-1 and the field order compared with offsetof. For each level it prints
// its value and its rank, the number of levels whose value is not greater.

module test_vpi_error_info_structure;
endmodule
