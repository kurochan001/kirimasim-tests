/*
:name: test_vpi_user_h_record_members
:description: vpi_user.h defines VPI_TIME and VPI_VECVAL and the fields, field order and typedef names of t_vpi_time, t_vpi_delay, t_vpi_vecval, t_vpi_strengthval, t_vpi_value, t_vpi_arrayvalue and t_vpi_systf_data as Annex K gives them (IEEE 1800-2023 Section 36.7, K.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_user_h_record_members.c
:expected_stdout: @test_vpi_user_h_record_members.expected
*/
// IEEE 1800-2023 §36.7: a VPI application includes vpi_user.h. K.2 fixes the
// value and delay structures of the header: t_vpi_time (inside the VPI_TIME
// guard), t_vpi_delay, t_vpi_vecval (inside the VPI_VECVAL guard),
// t_vpi_strengthval, t_vpi_value, t_vpi_arrayvalue and t_vpi_systf_data, with
// the type of each field, the order of the fields, the union of the value
// members, and the s_ and p_ typedef names of every structure.
//
// At the start of simulation (a cbStartOfSimulation callback, 38.36.3), the
// VPI application prints 1 for each check that holds: a field type compared
// at compile time (C11 _Generic in C, decltype in C++) with the type K.2
// gives, the field order and the common offset of the union members compared
// with offsetof, and the guards tested with #ifdef. A header that gives a
// field another type, reorders the fields or leaves a member out prints 0
// for the line of that check.

module test_vpi_user_h_record_members;
  initial $finish;
endmodule
