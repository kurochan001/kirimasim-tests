/*
:name: test_vpi_current_array_members_for_legacy_variable_kinds
:description: In current VPI mode integer, time and real unpacked arrays are array variables and only their elements have the array membership property
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 C.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_current_array_members_for_legacy_variable_kinds.c
:expected_stdout: @test_vpi_current_array_members_for_legacy_variable_kinds.expected
*/
module test_vpi_current_array_members_for_legacy_variable_kinds;
  integer int_array [3:2];
  integer int_scalar;
  time time_array [3:2];
  time time_scalar;
  real real_array [3:2];
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
