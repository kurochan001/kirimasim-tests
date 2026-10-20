/*
:name: test_dpi_shortreal
:description: A shortreal argument and result of an imported function pass as the C type float, so the C code computes in single precision (IEEE 1800-2023 Section 35.5.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.4 H.8.7 H.8.9 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_shortreal.c
:expected_stdout: @test_dpi_shortreal.expected
*/
// IEEE 1800-2023 §35.5.6, H.7.4: shortreal corresponds to the C type float.
// It is a small type, passed by value (H.8.7), and may be a function result
// (H.8.9). dpi_scale multiplies two floats. third holds 1.0 / 3.0 rounded to
// single precision (6.12), and dpi_is_third compares the float it gets with
// the float nearest to 1/3.

module test_dpi_shortreal;
  import "DPI-C" function shortreal dpi_scale(input shortreal x, input shortreal by);
  import "DPI-C" function int dpi_is_third(input shortreal x);

  shortreal third;

  initial begin
    third = 1.0 / 3.0;
    $display("1.5 * 2.5 = %0.2f", dpi_scale(1.5, 2.5));
    $display("1/3 arrives as a float: %0d", dpi_is_third(third));
  end
endmodule
