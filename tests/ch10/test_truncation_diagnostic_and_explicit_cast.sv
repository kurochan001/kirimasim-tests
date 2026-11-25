/*
:name: test_truncation_diagnostic_and_explicit_cast
:description: A narrowing assignment and an explicit size cast produce the same low bits
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_truncation_diagnostic_and_explicit_cast.expected
*/
module test_truncation_diagnostic_and_explicit_cast;
  bit [6:0] wide = 7'h63;
  bit [3:0] implicit_value, explicit_value;

  initial begin
    implicit_value = wide;
    explicit_value = 4'(wide);
    $display("implicit=%h explicit=%h", implicit_value, explicit_value);
    $finish(0);
  end
endmodule
