/*
:name: test_vpi_get_value_real_conversion
:description: vpi_get_value rounds a real object to the nearest integer, halves away from zero, for vpiIntVal and vpiDecStrVal, and gives it as a decimal floating-point string of at most 16 significant digits for vpiStringVal (IEEE 1800-2023 Section 38.15)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.15 6.12.1 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_get_value_real_conversion.c
:expected_stdout: @test_vpi_get_value_real_conversion.expected
*/
// IEEE 1800-2023 §38.15: a real object is converted to an integer with the
// rounding of 6.12.1 before it is returned in a format other than vpiRealVal
// and vpiStringVal: to the nearest integer, and a fraction of exactly 0.5 away
// from zero. With vpiStringVal it is returned as a floating-point number in
// decimal notation with at most 16 digits of precision. The application reads
// the real variables in a cbAfterDelay callback at 1 (38.36.2), registered at
// the start of the simulation (38.36.3). For vpiStringVal it prints whether
// the string has no exponent, whether it has at most 16 significant digits,
// and the number that strtod reads back from it, printed with %.10g.
// Icarus Verilog 13.0 rounds as expected but gives no string for vpiStringVal
// of a real variable.

`timescale 1ns/1ns

module test_vpi_get_value_real_conversion;
  real up_half, down_half, below_half, above_half, text_a, text_b;

  initial begin
    up_half = 2.5;
    down_half = -2.5;
    below_half = 7.49;
    above_half = -7.51;
    text_a = 1234.5;
    text_b = 0.1;
    #2 $finish;
  end
endmodule
