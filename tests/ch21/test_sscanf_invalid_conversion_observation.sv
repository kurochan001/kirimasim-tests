/*
:name: test_sscanf_invalid_conversion_observation
:description: A valid scan is followed by an invalid conversion in a separate build
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_invalid_conversion_observation.expected
*/
module test_sscanf_invalid_conversion_observation;
  int count, first = -11, second = -22;

  initial begin
    count = $sscanf("42 f", "%d %h", first, second);
    $display("defined count=%0d first=%0d second=%0d", count, first, second);
`ifdef OBSERVE_INVALID_SCAN
    first = -11;
    second = -22;
    $display("before invalid conversion");
    count = $sscanf("42 f", "%d %k", first, second);
    $display("observed count=%0d first=%0d second=%0d", count, first, second);
`endif
    $finish(0);
  end
endmodule
