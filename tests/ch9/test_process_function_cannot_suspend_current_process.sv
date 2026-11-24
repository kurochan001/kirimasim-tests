/*
:name: test_process_function_cannot_suspend_current_process
:description: A function calling suspend on its own process reports an error
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_function_cannot_suspend_current_process.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\bsuspend\b)(?=[^\n]*\b(?:self|own|current process|function)\b)[^\n]+
*/
`timescale 1ns/1ns
module test_process_function_cannot_suspend_current_process;
  function automatic void pause_target(std::process target);
    target.suspend();
  endfunction

  initial begin
    #1 $display("before self suspend");
    pause_target(std::process::self());
  end
  initial #10 $finish;
endmodule
