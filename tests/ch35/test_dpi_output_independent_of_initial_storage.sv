/*
:name: test_dpi_output_independent_of_initial_storage
:description: DPI output writes do not depend on the initial formal storage
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.2 H.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_dpi_output_independent_of_initial_storage
:dpi_c: @test_dpi_output_independent_of_initial_storage.c
:expected_stdout: @test_dpi_output_independent_of_initial_storage.expected
*/
`timescale 1ns/1ns
module test_dpi_output_independent_of_initial_storage;
  import "DPI-C" function void dpi_write_fresh_outputs(
      input int seed, output int number, output real fraction);

  int number;
  real fraction;

  initial begin
    number = 901;
    fraction = 7.25;
    dpi_write_fresh_outputs(11, number, fraction);
    $display("first value=%0d real=%0.1f", number, fraction);
    number = -502;
    fraction = 21.125;
    dpi_write_fresh_outputs(19, number, fraction);
    $display("second value=%0d real=%0.1f", number, fraction);
    $finish(0);
  end
endmodule
