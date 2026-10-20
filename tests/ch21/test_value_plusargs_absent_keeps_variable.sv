/*
:name: test_value_plusargs_absent_keeps_variable
:description: When no plusarg matches, $value$plusargs returns zero and leaves the variable as it was, also while other plusargs are given (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +present=1 +other=abc
:expected_stdout: @test_value_plusargs_absent_keeps_variable.expected
*/
// IEEE 1800-2023 §21.6: if no plusarg matches, $value$plusargs returns zero
// and does not modify its variable, and $test$plusargs returns zero; no
// warning is printed. The run has plusargs, but none named absent.

module test_value_plusargs_absent_keeps_variable;
  int v = 77;
  int r;

  initial begin
    r = $value$plusargs("absent=%d", v);
    $display("returned %0d, v=%0d", r, v);
    $display("test absent: %0d", $test$plusargs("absent") != 0);
    r = $value$plusargs("present=%d", v);
    $display("returned %0d, v=%0d", r != 0, v);
  end
endmodule
