/*
:name: test_vpi_systf_in_program_and_final
:description: A user-defined system task can be called from an initial procedure of a program and from a final procedure (IEEE 1800-2023 Sections 36.4 and 9.2.3)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9 24.3 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_program_and_final.c
:expected_stdout: @test_vpi_systf_in_program_and_final.expected
*/
// IEEE 1800-2023 §36.4: a user-defined system task is called like a built-in
// task, from any procedural code. §24.3: an initial procedure of a program is
// procedural code, so $vt_program_note runs there. §9.2.3: a final procedure
// runs when the simulation ends, and the system task in it, $vt_final_note,
// runs before the end. §36.9: the application registers both tasks from
// vlog_startup_routines. The program note comes at time 0 and the final note
// at 5, when $finish ends the simulation.

program p_note;
  initial $vt_program_note;
endprogram

module test_vpi_systf_in_program_and_final;
  initial #5 $finish;

  final $vt_final_note;
endmodule
