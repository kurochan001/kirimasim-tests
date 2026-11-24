/*
:name: test_dpi_open_array_pointer_range_checks
:description: DPI element pointer lookups return null outside unpacked array bounds
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6.1 I.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_open_array_pointer_range_checks.c
:expected_stdout: @test_dpi_open_array_pointer_range_checks.expected
*/
// The one-dimensional range descends. The second dimension ascends and
// has a negative lower bound. Check both limits of each dimension.
module test_dpi_open_array_pointer_range_checks;
  import "DPI-C" function int c_check_1d(input int source[]);
  import "DPI-C" function int c_check_2d(input int source[][]);
  int samples[4:2];
  int matrix[8:7][-3:-1];

  initial begin
    samples[3] = 23;
    matrix[8][-2] = 71;
    $display("one=%0d", c_check_1d(samples));
    $display("two=%0d", c_check_2d(matrix));
  end
endmodule
