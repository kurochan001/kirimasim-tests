/*
:name: test_finish_diagnostic_default
:description: A finish call without a diagnostic argument reports the time and call location as level one
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_finish_diagnostic_default.expected
:expected_stderr_regex: (?im)^[^\n]*test_finish_diagnostic_default\.sv:20\b[^\n]*\$finish[^\n]*\b37\b
*/
`timescale 1ns/1ns
module test_finish_diagnostic_default;
  initial begin
    #37;
    $display("finish request at %0d", $time);
    $finish;
    #5;
    $display("execution after finish");
  end
endmodule
