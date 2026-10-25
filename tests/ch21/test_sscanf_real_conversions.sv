/*
:name: test_sscanf_real_conversions
:description: $sscanf %f, %e and %g read a floating-point number with an optional sign, digits with an optional decimal point and an optional exponent of e or E with an optional sign, and the field ends at the first character outside that form (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_real_conversions.expected
*/
// IEEE 1800-2023 §21.3.4.3, Table 21-7: %f, %e and %g all match a
// floating-point number: an optional + or - sign, a string of decimal digits
// that may contain a decimal point, and an optional exponent part of e or E,
// an optional sign and decimal digits. Each code reads numbers with and
// without a decimal point, with and without an exponent and with either sign.
// The field ends at x, which is left for %s; a letter where a number is
// expected is a matching failure, so the result is 0 and the variable keeps
// its value. The values are printed with four decimals.

module test_sscanf_real_conversions;
  real r;
  string rest;
  int n;

  initial begin
    n = $sscanf("+1.5", "%f", r);      $display("%%f +1.5: n=%0d %0.4f", n, r);
    n = $sscanf("7", "%f", r);         $display("%%f 7: n=%0d %0.4f", n, r);
    n = $sscanf("-2.25e2", "%e", r);   $display("%%e -2.25e2: n=%0d %0.4f", n, r);
    n = $sscanf("-12.5e+1", "%e", r);  $display("%%e -12.5e+1: n=%0d %0.4f", n, r);
    n = $sscanf("3E-1", "%g", r);      $display("%%g 3E-1: n=%0d %0.4f", n, r);
    n = $sscanf("6.25E-2", "%g", r);   $display("%%g 6.25E-2: n=%0d %0.4f", n, r);
    n = $sscanf("1.5x", "%f%s", r, rest);
    $display("%%f%%s 1.5x: n=%0d %0.4f %s", n, r, rest);
    r = 9.0;
    n = $sscanf("abc", "%e", r);       $display("%%e abc: n=%0d %0.4f", n, r);
  end
endmodule
