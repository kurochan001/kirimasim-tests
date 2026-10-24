/*
:name: test_vpi_value_time_delay_structures
:description: vpi_user.h defines s_vpi_time, s_vpi_delay, s_vpi_value, s_vpi_vecval and s_vpi_strengthval with the fields, field types and order of their figures, the time types, logic values and strengths they use, and the routines that take them (IEEE 1800-2023 Sections 38.10, 38.13, 38.15, 38.32 and 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.10 38.13 38.15 38.32 38.34 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_value_time_delay_structures.c
:expected_stdout: @test_vpi_value_time_delay_structures.expected
*/
// IEEE 1800-2023 §38.13 (Figure 38-6), §38.10 (Figure 38-3), §38.32,
// §38.34: s_vpi_time has type (PLI_INT32), high and low (PLI_UINT32) and real
// (double); its type is vpiScaledRealTime, vpiSimTime or vpiSuppressTime.
// s_vpi_delay has da (struct t_vpi_time *) and then the PLI_INT32 fields
// no_of_delays, time_type, mtm_flag, append_flag and pulsere_flag. §38.15
// (Figures 38-7 to 38-9), §38.34: s_vpi_value has format (PLI_INT32) and a
// union value of str (PLI_BYTE8 *), scalar and integer (PLI_INT32), real
// (double), time, vector and strength (pointers to t_vpi_time, t_vpi_vecval
// and t_vpi_strengthval) and misc (PLI_BYTE8 *); s_vpi_vecval has aval and
// bval (PLI_UINT32); s_vpi_strengthval has logic, s0 and s1 (PLI_INT32),
// logic being vpi0, vpi1, vpiX or vpiZ and the strengths coded as in Annex
// K. Each typedef also has a p_ pointer type. vpi_get_time, vpi_get_delays,
// vpi_put_delays, vpi_get_value and vpi_put_value take these structures.
//
// At the start of the simulation (a cbStartOfSimulation callback, 38.36.3),
// the VPI application prints 1 for each check that holds: a type compared at
// compile time (C11 _Generic in C, decltype in C++) and an order or a union
// compared with offsetof. It also prints the constants with the values that
// K.2 gives them.
// The vpi_user.h of Icarus Verilog 13.0 declares aval and bval as PLI_INT32.

module test_vpi_value_time_delay_structures;
endmodule
