/*
:name: test_vpi_base_object_code_reservations
:description: Base VPI object codes coexist with extension object codes and base aliases
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.7 K.2 M.2 37.3.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_base_object_code_reservations.c
:expected_stdout: @test_vpi_base_object_code_reservations.expected
*/
module test_vpi_base_object_code_reservations;
  initial #1 $finish(0);
endmodule
