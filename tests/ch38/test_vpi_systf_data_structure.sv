/*
:name: test_vpi_systf_data_structure
:description: vpi_user.h defines s_vpi_systf_data with the fields of Figure 38-18, their types and their order, and the s_ and p_ typedef names (IEEE 1800-2023 Section 38.37)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37 38.36.3 36.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_data_structure.c
:expected_stdout: @test_vpi_systf_data_structure.expected
*/
// IEEE 1800-2023 §38.37: vpi_register_systf takes a pointer to an
// s_vpi_systf_data structure, which vpi_user.h defines (Figure 38-18): the
// structure t_vpi_systf_data with the typedef names s_vpi_systf_data and
// p_vpi_systf_data (a pointer), holding in this order the PLI_INT32 type and
// sysfunctype, the PLI_BYTE8* tfname, the name whose first character is $,
// the calltf, compiletf and sizetf routine pointers, each returning PLI_INT32
// and taking a PLI_BYTE8*, and the PLI_BYTE8* user_data.
//
// At the start of the simulation (a cbStartOfSimulation callback, 38.36.3)
// the VPI application prints 1 for each check that holds: a type compared at
// compile time with the one of Figure 38-18 (C11 _Generic in C, decltype in
// C++) and the field order compared with offsetof. A different type or order
// prints 0, and a missing field does not compile.
//
// The vpi_user.h of Icarus Verilog 13.0 declares tfname as const char* (see
// the simulator differences document), so its tfname line prints 0.

module test_vpi_systf_data_structure;
endmodule
