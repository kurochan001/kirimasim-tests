/*
:name: test_finish_diagnostic_one
:description: An explicit finish diagnostic level of one reports the simulation time and call location
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_finish_diagnostic_one.expected
:expected_stderr_regex: (?im)^[^\n]*test_finish_diagnostic_one\.sv:20\b[^\n]*\$finish[^\n]*\b37\b
*/
`timescale 1ns/1ns
module test_finish_diagnostic_one;
  initial begin
    #37;
    $display("finish request at %0d", $time);
    $finish(1);
    #5;
    $display("execution after finish");
  end
endmodule
