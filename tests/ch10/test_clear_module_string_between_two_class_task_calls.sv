/*
:name: test_clear_module_string_between_two_class_task_calls
:description: Clearing a module string takes effect between two calls to a writer task (IEEE 1800-2023 Section 10.4.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 23.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clear_module_string_between_two_class_task_calls.expected
:expected_exit: 0
*/
// Both tasks refer to the same module variable. Blocking assignment clears it
// immediately; the next writer appends one M to the empty string.

module test_clear_module_string_between_two_class_task_calls;
  string trace = "";
  class writer;
    task append();
      trace = {trace, "M"};
    endtask
  endclass
  class runner;
    writer w = new;
    task run();
      w.append();
      $display("CHECK first=<%s>", trace);
      trace = "";
      $display("CHECK cleared=<%s>", trace);
      w.append();
      $display("CHECK second=<%s>", trace);
    endtask
  endclass

  initial begin
    automatic runner r = new;
    r.run();
    $finish;
  end
endmodule
