/*
:name: test_program_hierarchical_reference_between_programs
:description: A hierarchical reference can go from one program to a variable and a task of another program (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 24.5 23.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_hierarchical_reference_between_programs.expected
*/
// IEEE 1800-2023 §24.3: references to program signals from outside every
// program are errors, but hierarchical references from one program scope to
// another program scope are legal. §24.5: a program can call the subroutines
// of another program. The reader program reads the counter of the writer
// program one time unit after the writer has changed it, and calls its task.

program test_program_hierarchical_reference_between_programs_w;
  int counter = 10;
  task automatic bump(int by);
    counter += by;
  endtask
  initial counter = 20;
endprogram

program test_program_hierarchical_reference_between_programs_r;
  initial begin
    #1 $display("read counter=%0d", test_program_hierarchical_reference_between_programs.w.counter);
    test_program_hierarchical_reference_between_programs.w.bump(5);
    $display("after bump counter=%0d",
             test_program_hierarchical_reference_between_programs.w.counter);
  end
endprogram

module test_program_hierarchical_reference_between_programs;
  test_program_hierarchical_reference_between_programs_w w();
  test_program_hierarchical_reference_between_programs_r r();
endmodule
