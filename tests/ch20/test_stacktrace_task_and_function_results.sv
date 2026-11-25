/*
:name: test_stacktrace_task_and_function_results
:description: The stacktrace function returns a string silently and the task displays the current stack
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stacktrace_task_and_function_results.expected
*/
// The checked output records delivery and frame identity. The
// implementation's original trace formatting is interpreted by
// tools/run_stacktrace.py.
module test_stacktrace_task_and_function_results;
  task automatic inspect_result();
    string trace;

    $display("CAPTURE_BEGIN");
    trace = $stacktrace;
    $display("CAPTURE_END");
    $display("type=%s nonempty=%0d", $typename($stacktrace), trace.len() != 0);
    $display("RETURN_BEGIN");
    $display("%s", trace);
    $display("RETURN_END");
    $display("TASK_BEGIN");
    $stacktrace;
    $display("TASK_END");
  endtask

  initial inspect_result();
endmodule
