/*
:name: test_stacktrace_resumed_task_context
:description: The stacktrace call sees the active task and its caller before suspension and again after resumption
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stacktrace_resumed_task_context.expected
*/
// Read the same live task chain before and after a delay, then observe
// the initial process after both tasks return. tools/run_stacktrace.py
// records only the ordered frame identities for comparison.
`timescale 1ns/1ns
module test_stacktrace_resumed_task_context;
  function automatic string capture_context();
    return $stacktrace;
  endfunction

  task automatic inner_task();
    $display("INITIAL_BEGIN");
    $stacktrace;
    $display("INITIAL_END");
    #1;
    $display("RESUME_BEGIN");
    $display("%s", capture_context());
    $display("RESUME_END");
  endtask

  task automatic outer_task();
    inner_task();
  endtask

  initial begin
    outer_task();
    $display("AFTER_BEGIN");
    $stacktrace;
    $display("AFTER_END");
  end
endmodule
