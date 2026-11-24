/*
:name: test_vpi_legacy_array_property_in_1364v2005_mode
:description: In IEEE 1364-2005 compatibility mode the deprecated array property distinguishes integer, time and real arrays from scalars of the same types
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.12.1 36.12.2.1 37.17 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_legacy_array_property_in_1364v2005_mode.c
:expected_stdout: @test_vpi_legacy_array_property_in_1364v2005_mode.expected
*/
module test_vpi_legacy_array_property_in_1364v2005_mode;
  integer int_array [2:3];
  integer int_scalar;
  time time_array [2:3];
  time time_scalar;
  real real_array [2:3];
  real real_scalar;

  initial begin
    int_array[2] = 12;
    int_scalar = 8;
    time_array[2] = 14;
    time_scalar = 9;
    real_array[2] = 1.5;
    real_scalar = 2.5;
    #1 $display("design=%0d/%0d %0d/%0d %0.1f/%0.1f",
                int_scalar, int_array[2], time_scalar, time_array[2],
                real_scalar, real_array[2]);
  end
endmodule
