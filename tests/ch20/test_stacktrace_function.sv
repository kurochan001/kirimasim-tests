/*
:name: test_stacktrace_function
:description: $stacktrace called as a function returns the call stack as a string, whose content is up to the implementation (IEEE 1800-2023 Section 20.17.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stacktrace_function.expected
*/
// IEEE 1800-2023 §20.17.2: $stacktrace gives the call stack from where it is
// called up to the top-level process; as a task it prints it, and as a
// function it returns it as a string. The content is implementation
// dependent, so the test only checks that the string from inside two nested
// task calls is not empty, and does not call the task form, whose output it
// could not compare.
//
// Icarus Verilog 13.0 stops on an internal assertion when it compiles the
// call.

module test_stacktrace_function;
  string trace;

  task automatic inner();
    trace = $stacktrace;
  endtask

  task automatic outer();
    inner();
  endtask

  initial begin
    outer();
    $display("stack trace returned: %0d", trace.len() > 0);
  end
endmodule
