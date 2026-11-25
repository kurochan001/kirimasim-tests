/*
:name: test_real_power_unspecified_domain_values
:description: Real power has defined results beside two unspecified operand pairs
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_power_unspecified_domain_values.expected
*/
module test_real_power_unspecified_domain_values;
  real zero = 0.0, negative = -9.0, positive = 9.0;
  real fraction = 0.5, integer_value = 2.0, negative_exponent = -1.0;

  initial begin
    $display("defined=%0.1f,%0.1f,%0.1f", zero ** integer_value,
             negative ** integer_value, positive ** fraction);

    // The bit patterns in these probes are observations only.
    if ($test$plusargs("observe_zero_negative"))
      $display("zero_to_negative=%016h", $realtobits(zero ** negative_exponent));
    if ($test$plusargs("observe_negative_fractional"))
      $display("negative_to_fractional=%016h", $realtobits(negative ** fraction));
    $finish(0);
  end
endmodule
