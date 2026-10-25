/*
:name: test_value_plusargs_not_found_silent
:description: When no plusarg matches, $value$plusargs returns zero and leaves its variable unchanged, for integral, real and string variables, and no warning is printed (IEEE 1800-2023 Section 21.6)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +present=5 +absent_not_quite
:expected_exit: 0
:expected_stdout: @test_value_plusargs_not_found_silent.expected
:expected_stderr_regex: \A(?![\s\S]*(?i:warn(?:ing)?))[\s\S]*\Z
*/
// IEEE 1800-2023 §21.6: if no plusarg matches the plusarg string of
// $value$plusargs, the function returns zero, the variable is not modified,
// and no warning shall be generated. The run gets +present=5 and
// +absent_not_quite (:args:); the keys absent= with %d, %f and %s match
// neither, since a plusarg has to start with the whole key. The messages of
// the run must not contain the word warning.

module test_value_plusargs_not_found_silent;
  int d;
  real r;
  string s;
  int found;

  initial begin
    d = 77;
    r = 1.25;
    s = "kept";
    found = $value$plusargs("absent=%d", d);
    $display("%%d: found=%0d d=%0d", found, d);
    found = $value$plusargs("absent=%f", r);
    $display("%%f: found=%0d r=%0.2f", found, r);
    found = $value$plusargs("absent=%s", s);
    $display("%%s: found=%0d s=%s", found, s);
    found = $value$plusargs("present=%d", d);
    $display("present: found=%0d d=%0d", found != 0, d);
  end
endmodule
