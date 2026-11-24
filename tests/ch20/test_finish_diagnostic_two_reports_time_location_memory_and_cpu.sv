/*
:name: test_finish_diagnostic_two_reports_time_location_memory_and_cpu
:description: A level-two finish reports time, location, memory and CPU statistics and ends simulation
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_finish_diagnostic_two_reports_time_location_memory_and_cpu.expected
:expected_stderr_regex: \A(?=[\s\S]*(?im:^[^\n]*(?:\$finish\b|simulation time)[^\n]*\b37\b))(?=[\s\S]*(?im:^[^\n]*(?:\.sv:20\b|\blocation\b)))(?=[\s\S]*(?im:^(?=[^\n]*\d)[^\n]*\b(?:memory|RSS|heap)\b))(?=[\s\S]*(?im:^(?=[^\n]*\d)[^\n]*\b(?:CPU|processor)\b))
*/
`timescale 1ns/1ns
module test_finish_diagnostic_two_reports_time_location_memory_and_cpu;
  initial begin
    #37;
    $display("finish request at %0d", $time);
    $finish(2);
    #5 $display("execution after finish");
  end
endmodule
