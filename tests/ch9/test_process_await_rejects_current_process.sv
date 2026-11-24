/*
:name: test_process_await_rejects_current_process
:description: A process cannot await itself
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_await_rejects_current_process.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\bawait\b)(?=[^\n]*\b(?:self|itself|current process)\b)[^\n]+
*/
`timescale 1ns/1ns
module test_process_await_rejects_current_process;
  initial begin
    std::process current;
    #1;
    current = std::process::self();
    $display("before await");
    current.await();
  end
  initial #10 $finish;
endmodule
