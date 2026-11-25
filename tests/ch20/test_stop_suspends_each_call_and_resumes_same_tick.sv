/*
:name: test_stop_suspends_each_call_and_resumes_same_tick
:description: Each stop suspends execution until a debugger command resumes it at the same time
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stop_suspends_each_call_and_resumes_same_tick.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module test_stop_suspends_each_call_and_resumes_same_tick;
  initial begin
    #7 $display("first stop at %0d", $time);
    $stop(0);
    $display("first resume at %0d", $time);
    #4 $display("second stop at %0d", $time);
    $stop(1);
    $display("second resume at %0d", $time);
    #3 $display("finish at %0d", $time);
    $finish(0);
  end
endmodule
