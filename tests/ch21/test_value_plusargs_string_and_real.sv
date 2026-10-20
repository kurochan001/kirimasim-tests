/*
:name: test_value_plusargs_string_and_real
:description: $value$plusargs stores the rest of a matching plusarg unconverted with %s, and as a real number with %f and %e (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +name=alpha_7 +ratio=2.5 +scale=1.25e3
:expected_stdout: @test_value_plusargs_string_and_real.expected
*/
// IEEE 1800-2023 §21.6: %s stores the rest of the plusarg as a string with no
// conversion, and %f and %e convert it to a real number. The run gets a name,
// a ratio in decimal notation and a scale in exponential notation.

module test_value_plusargs_string_and_real;
  string name;
  real ratio, scale;

  initial begin
    if ($value$plusargs("name=%s", name)) $display("name=%s", name);
    if ($value$plusargs("ratio=%f", ratio)) $display("ratio=%0.2f", ratio);
    if ($value$plusargs("scale=%e", scale)) $display("scale=%0.1f", scale);
  end
endmodule
