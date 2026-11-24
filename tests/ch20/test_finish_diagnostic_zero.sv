/*
:name: test_finish_diagnostic_zero
:description: An explicit finish diagnostic level of zero exits without printing a finish message
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_finish_diagnostic_zero.expected
:expected_stderr_regex: \A(?![\s\S]*\$finish\b)
*/
`timescale 1ns/1ns
module test_finish_diagnostic_zero;
  initial begin
    #37;
    $display("finish request at %0d", $time);
    $finish(0);
    #5;
    $display("execution after finish");
  end
endmodule
