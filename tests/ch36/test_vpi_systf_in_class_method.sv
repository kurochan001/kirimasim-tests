/*
:name: test_vpi_systf_in_class_method
:description: A user-defined system task can be called from a task of a class (IEEE 1800-2023 Section 36.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.4 36.9.1 8.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_in_class_method.c
:expected_stdout: @test_vpi_systf_in_class_method.expected
*/
// IEEE 1800-2023 §36.4: a user-defined system task is called like a built-in
// task from any procedural code. §8.6: the method note of the class note_c is
// a task, so $vt_note is called there when the method runs. §36.9.1: the
// application registers $vt_note from vlog_startup_routines.

class note_c;
  task automatic note();
    $vt_note;
  endtask
endclass

module test_vpi_systf_in_class_method;
  initial begin
    note_c h;
    h = new;
    h.note;
  end
endmodule
