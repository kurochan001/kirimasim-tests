/*
:name: test_program_calls_module_task
:description: A task declared in a module runs in the reactive region set when a program calls it, so it sees the nonblocking updates of the design in the same time step, while the same task called from the module does not (IEEE 1800-2023 Section 24.5)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.5 24.3.1 4.4.2.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_calls_module_task.expected
*/
// IEEE 1800-2023 §24.5, §24.3.1: a program may call a task of a design module,
// and the task then runs in the reactive region set, like the program thread
// that calls it. At 10 the module updates b with a nonblocking assignment.
// The module's own call of copy_b at 10 runs in the Active region, before
// that update, and copies 0. The program's call at 10 runs in the Reactive
// region, after the NBA region (4.4.2.6), and copies 1. After its delay of 5
// the task, still in the program's thread, copies b again in the Reactive
// region at 15, where the module has set b to 2 in the Active region.

module test_program_calls_module_task;
  int b = 0;
  int seen_by_module = -1, seen_by_program = -1, later = -1;

  task automatic copy_b(output int now, output int after);
    now = b;
    #5 after = b;
  endtask

  initial begin
    #10 b <= 1;
    #5 b = 2;
  end

  initial begin
    int unused;
    #10 copy_b(seen_by_module, unused);
  end

  program p;
    initial begin
      #10 copy_b(seen_by_program, later);
      $display("module call: %0d, program call: %0d, after the delay: %0d",
               seen_by_module, seen_by_program, later);
    end
  endprogram
endmodule
